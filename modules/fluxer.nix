{ ... }:
{
  flake.nixosModules.fluxer =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      secret = config.sops.placeholder;
      domain = "lain.tailc113f2.ts.net";

      # Mirrors the Caddyfile from the upstream Docker Compose bundle:
      # https://fluxer.dev/compose/latest
      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          servers {
            trusted_proxies static {''$FLUXER_EDGE_TRUSTED_PROXIES:private_ranges}
            trusted_proxies_strict
            protocols {''$FLUXER_EDGE_PROTOCOLS:h1 h2 h3}
          }
          {''$FLUXER_EDGE_GLOBAL_OPTIONS}
        }

        (upstream) {
          reverse_proxy {args[0]} {
            header_up X-Forwarded-For {client_ip}
            header_up X-Real-IP {client_ip}
            header_up -Forwarded
          }
        }

        {''$FLUXER_EDGE_SITE_ADDRESS} {
          {''$FLUXER_EDGE_TLS_DIRECTIVE}
          encode {''$FLUXER_EDGE_ENCODE:zstd gzip}

          handle /_health {
            respond "OK" 200
          }

          handle /_edge {
            header Cache-Control no-store
            respond "{system.hostname}" 200
          }

          handle_path /api/* {
            import upstream api:8080
          }

          handle /gateway {
            rewrite * /
            import upstream gateway:8080
          }

          handle_path /gateway/* {
            import upstream gateway:8080
          }

          handle_path /media/* {
            import upstream media-proxy:8080
          }

          handle_path /livekit/* {
            import upstream livekit:7880
          }

          handle {''$FLUXER_ADMIN_BASE_PATH:/admin} {
            rewrite * /
            import upstream admin:8080
          }

          handle_path {''$FLUXER_ADMIN_BASE_PATH:/admin}/* {
            import upstream admin:8080
          }

          @staticAssets path /web/* /emoji/* /libs/* /avatars/* /badges/* /desktop/*
          handle @staticAssets {
            import upstream static-proxy:8080
          }

          handle /.well-known/fluxer {
            import upstream api:8080
          }

          handle {
            import upstream app-proxy:8080
          }
        }

        :8088 {
          handle /.well-known/fluxer {
            import upstream api:8080
          }

          handle /_edge {
            respond "{system.hostname}" 200
          }
        }
      '';

      # Healthchecks (JSON arrays, passed to podman's --health-cmd).
      hcExec = args: builtins.toJSON ([ "CMD" ] ++ args);
      hcHttp =
        port: path:
        builtins.toJSON [
          "CMD"
          "bash"
          "-c"
          "exec 3<>/dev/tcp/127.0.0.1/${toString port} && printf 'GET ${path} HTTP/1.0\\r\\nHost: 127.0.0.1\\r\\n\\r\\n' >&3 && head -n 1 <&3 | grep -q ' 200 '"
        ];
      hcSvc = hcHttp 8090 "/_health";
      hcAdmin = hcHttp 8080 "/_health";
      hcApi = hcHttp 8080 "/_health";
      hcGateway = hcHttp 8080 "/_health/ready";
      hcWorker = hcExec [
        "bash"
        "-c"
        "find /tmp/fluxer-worker-heartbeat -newermt '-30 seconds' | grep -q ."
      ];
      hcWget =
        url:
        hcExec [
          "wget"
          "-q"
          "-O"
          "/dev/null"
          url
        ];
      hcCurl =
        url:
        hcExec [
          "curl"
          "-fsS"
          "-o"
          "/dev/null"
          url
        ];

      seaweedfsInitEntrypoint = builtins.toJSON [
        "/bin/sh"
        "-c"
        ''
          buckets="$FLUXER_S3_BUCKET_CDN $FLUXER_S3_BUCKET_UPLOADS $FLUXER_S3_BUCKET_REPORTS $FLUXER_S3_BUCKET_HARVESTS";
          missing="$buckets";
          failure="";
          for attempt in $(seq 1 "''${FLUXER_SEAWEEDFS_INIT_ATTEMPTS:-60}"); do
            if ! nc -z seaweedfs 9333 2>/dev/null; then
              sleep 2;
              continue;
            fi;
            listed=$(echo "s3.bucket.list" | timeout 10 weed shell -master=seaweedfs:9333 2>&1);
            missing="";
            for b in $buckets; do
              echo "$listed" | grep -q "^[[:space:]]*$b[[:space:]]" || missing="''${missing:+$missing }$b";
            done;
            if [ -z "$missing" ]; then
              if [ "$FLUXER_SEAWEEDFS_UPLOADS_TTL" = off ]; then
                ttl_rule="fs.configure -locationPrefix=/buckets/$FLUXER_S3_BUCKET_UPLOADS/ -delete -apply";
              else
                ttl_rule="fs.configure -locationPrefix=/buckets/$FLUXER_S3_BUCKET_UPLOADS/ -ttl=$FLUXER_SEAWEEDFS_UPLOADS_TTL -apply";
              fi;
              failure="could not configure the S3 identity";
              if echo "s3.configure -user=fluxer -access_key=$FLUXER_S3_ACCESS_KEY -secret_key=$FLUXER_S3_SECRET_KEY -actions=Admin,Read,Write,List,Tagging -apply" | timeout 10 weed shell -master=seaweedfs:9333 >/dev/null 2>&1; then
                failure="could not set the expiry of $FLUXER_S3_BUCKET_UPLOADS";
                if echo "$ttl_rule" | timeout 10 weed shell -master=seaweedfs:9333 >/dev/null 2>&1; then
                  echo "buckets ready";
                  exit 0;
                fi;
              fi;
              sleep 2;
              continue;
            fi;
            for b in $missing; do
              echo "s3.bucket.create -name $b" | timeout 10 weed shell -master=seaweedfs:9333 >/dev/null 2>&1;
            done;
            sleep 2;
          done;
          if [ -n "$failure" ]; then
            echo "seaweedfs-init $failure" >&2;
          else
            echo "seaweedfs-init could not verify buckets: $missing" >&2;
          fi;
          exit 1;
        ''
      ];

      # ---- Generated systemd wiring ----
      netSvc = "podman-network-fluxer_fluxer.service";

      # Every container's systemd unit is identical: a restart policy
      # composition2nix set plus a hard dep on the shared compose network
      # and on each named volume the container binds (if any).
      # NOTE: both generators return { "<unit-name>" = { ... }; } attrsets,
      # which the caller merges into `systemd.services` (do NOT wrap them
      # again in systemd.services here).
      podmanService =
        name:
        {
          volumes ? [ ],
          restart ? "always",
        }:
        let
          volUnits = map (v: "podman-volume-${v}.service") volumes;
        in
        {
          "podman-${name}" = {
            serviceConfig = {
              Restart = lib.mkOverride 90 restart;
            }
            // lib.optionalAttrs (restart != "no") {
              RestartMaxDelaySec = lib.mkOverride 90 "1m";
              RestartSec = lib.mkOverride 90 "100ms";
              RestartSteps = lib.mkOverride 90 9;
            };
            after = [ netSvc ] ++ volUnits;
            requires = [ netSvc ] ++ volUnits;
            partOf = [ "podman-compose-fluxer-root.target" ];
            wantedBy = [ "podman-compose-fluxer-root.target" ];
          };
        };

      # `podman volume create` oneshot for a named compose volume.
      volumeService = name: {
        "podman-volume-${name}" = {
          path = [ pkgs.podman ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            podman volume inspect ${name} || podman volume create ${name}
          '';
          partOf = [ "podman-compose-fluxer-root.target" ];
          wantedBy = [ "podman-compose-fluxer-root.target" ];
        };
      };

      # Named volumes the compose project uses.
      fluxerVolumes = [
        "fluxer_edge-config"
        "fluxer_edge-data"
        "fluxer_media-proxy-tmp"
        "fluxer_meilisearch-data"
        "fluxer_nats-data"
        "fluxer_postgres-data"
        "fluxer_seaweedfs-data"
        "fluxer_valkey-data"
      ];

      # Per-container wiring: which named volumes it binds, and any
      # overrides. seaweedfs-init is a one-shot bootstrap job, so it
      # must not restart.
      serviceWiring = {
        "fluxer-admin" = { };
        "fluxer-api" = { };
        "fluxer-app-proxy" = { };
        "fluxer-edge" = {
          volumes = [
            "fluxer_edge-config"
            "fluxer_edge-data"
          ];
        };
        "fluxer-gateway" = { };
        "fluxer-gifs" = { };
        "fluxer-livekit" = { };
        "fluxer-media-proxy" = {
          volumes = [ "fluxer_media-proxy-tmp" ];
        };
        "fluxer-push" = { };
        "fluxer-meilisearch" = {
          volumes = [ "fluxer_meilisearch-data" ];
        };
        "fluxer-messages" = { };
        "fluxer-nats" = {
          volumes = [ "fluxer_nats-data" ];
        };
        "fluxer-postgres" = {
          volumes = [ "fluxer_postgres-data" ];
        };
        "fluxer-seaweedfs" = {
          volumes = [ "fluxer_seaweedfs-data" ];
        };
        "fluxer-seaweedfs-init" = {
          restart = "no";
        };
        "fluxer-snowflakes" = { };
        "fluxer-static-proxy" = { };
        "fluxer-unfurl" = { };
        "fluxer-users" = { };
        "fluxer-valkey" = {
          volumes = [ "fluxer_valkey-data" ];
        };
        "fluxer-worker" = { };
      };
    in
    {
      networking.firewall.interfaces =
        let
          matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
        in
        {
          "${matchAll}".allowedUDPPorts = [ 53 ];
        };
      virtualisation.oci-containers.backend = "podman";

      sops.secrets = {
        "fluxer/domain" = { };
        "fluxer/postgres_password" = { };
        "fluxer/meili_master_key" = { };
        "fluxer/s3_secret_key" = { };
        "fluxer/sudo_mode_secret" = { };
        "fluxer/connection_initiation_secret" = { };
        "fluxer/profile_pseudonym_secret" = { };
        "fluxer/gateway_rpc_auth_token" = { };
        "fluxer/erlang_cookie" = { };
        "fluxer/media_proxy_secret_key" = { };
        "fluxer/media_proxy_upload_relay_secret" = { };
        "fluxer/admin_secret_key_base" = { };
        "fluxer/admin_oauth_client_secret" = { };
        "fluxer/vapid_private_key" = { };
        "fluxer/livekit_api_secret" = { };
        "fluxer/livekit_node_ip" = { };
      };
      sops.templates."fluxer-env" = {
        content = ''
          FLUXER_ENV=production
          LOG_LEVEL=info
          FLUXER_SELF_HOSTED=true
          FLUXER_BASE_DOMAIN=${secret."fluxer/domain"}
          FLUXER_PUBLIC_SCHEME=https
          FLUXER_PUBLIC_PORT=443
          FLUXER_TRUST_CLIENT_IP_HEADER=true
          FLUXER_CLIENT_IP_HEADER_NAME=x-forwarded-for
          FLUXER_API_HEADERS_TIMEOUT_MS=30000
          FLUXER_API_REQUEST_TIMEOUT_MS=120000
          FLUXER_DATABASE_BACKEND=postgres
          FLUXER_POSTGRES_HOST=postgres
          FLUXER_POSTGRES_PORT=5432
          FLUXER_POSTGRES_DATABASE=fluxer
          FLUXER_POSTGRES_USERNAME=fluxer
          FLUXER_POSTGRES_PASSWORD=${secret."fluxer/postgres_password"}
          FLUXER_POSTGRES_SSL=false
          FLUXER_POSTGRES_PREPARED_STATEMENTS=true
          FLUXER_KV_URL=redis://valkey:6379/0
          FLUXER_NATS_URL=nats://nats:4222
          FLUXER_NATS_JETSTREAM_URL=nats://nats:4222
          FLUXER_SVC_NATS_URL=nats://nats:4222
          FLUXER_SVC_SHARD_COUNT=1
          FLUXER_SEARCH_ENGINE=meilisearch
          FLUXER_SEARCH_URL=http://meilisearch:7700
          FLUXER_SEARCH_API_KEY=${secret."fluxer/meili_master_key"}
          FLUXER_S3_ENDPOINT=http://seaweedfs:8333
          FLUXER_S3_PUBLIC_ENDPOINT=http://seaweedfs:8333
          FLUXER_S3_REGION=us-east-1
          FLUXER_S3_ACCESS_KEY_ID=fluxer
          FLUXER_S3_SECRET_ACCESS_KEY=${secret."fluxer/s3_secret_key"}
          FLUXER_S3_ACCESS_KEY=fluxer
          FLUXER_S3_SECRET_KEY=${secret."fluxer/s3_secret_key"}
          FLUXER_S3_FORCE_PATH_STYLE=true
          FLUXER_S3_BUCKET_CDN=fluxer
          FLUXER_S3_BUCKET_UPLOADS=fluxer-uploads
          FLUXER_S3_BUCKET_REPORTS=fluxer-reports
          FLUXER_S3_BUCKET_HARVESTS=fluxer-harvests
          AWS_ACCESS_KEY_ID=fluxer
          AWS_SECRET_ACCESS_KEY=${secret."fluxer/s3_secret_key"}
          AWS_DEFAULT_REGION=us-east-1
          AWS_EC2_METADATA_DISABLED=true
          FLUXER_SEAWEEDFS_INIT_ATTEMPTS=60
          FLUXER_SEAWEEDFS_UPLOADS_TTL=1d
          FLUXER_LIVEKIT_ENABLED=true
          FLUXER_LIVEKIT_API_KEY=fluxer
          FLUXER_LIVEKIT_API_SECRET=${secret."fluxer/livekit_api_secret"}
          FLUXER_LIVEKIT_INTERNAL_URL=http://livekit:7880
          FLUXER_LIVEKIT_URL=https://${secret."fluxer/domain"}/livekit
          FLUXER_LIVEKIT_DEFAULT_REGION={"id":"default","name":"Default","emoji":"🌍","latitude":0,"longitude":0}
          FLUXER_KLIPY_API_KEY=
          FLUXER_EMAIL_ENABLED=false
          FLUXER_EMAIL_PROVIDER=none
          FLUXER_EMAIL_FROM_EMAIL=noreply@${secret."fluxer/domain"}
          FLUXER_EMAIL_FROM_NAME=Fluxer
          FLUXER_EMAIL_SMTP_HOST=
          FLUXER_EMAIL_SMTP_PORT=587
          FLUXER_EMAIL_SMTP_USERNAME=
          FLUXER_EMAIL_SMTP_PASSWORD=
          FLUXER_EMAIL_SMTP_SECURE=true
          FLUXER_CAPTCHA_ENABLED=false
          FLUXER_CAPTCHA_PROVIDER=none
          FLUXER_STRIPE_ENABLED=false
          FLUXER_NCMEC_ENABLED=false
          FLUXER_CLAMAV_ENABLED=false
          FLUXER_DISCOVERY_ENABLED=true
          FLUXER_SUDO_MODE_SECRET=${secret."fluxer/sudo_mode_secret"}
          FLUXER_CONNECTION_INITIATION_SECRET=${secret."fluxer/connection_initiation_secret"}
          FLUXER_PROFILE_PSEUDONYM_SECRET=${secret."fluxer/profile_pseudonym_secret"}
          FLUXER_SSO_ALLOW_PRIVATE_ADDRESSES=false
          FLUXER_VAPID_PUBLIC_KEY=BLFtEENtXI2kDpLjP92GTmi8uSOJscnc13KBhdA2WtYFbXpK5kYuGEfskOzo9qRaVh5rTBLSWbE1svabHZC9Qds
          FLUXER_VAPID_PRIVATE_KEY=${secret."fluxer/vapid_private_key"}
          FLUXER_VAPID_EMAIL=admin@${secret."fluxer/domain"}
          FLUXER_PASSKEY_RP_ID=${secret."fluxer/domain"}
          FLUXER_PASSKEY_RP_NAME=Fluxer
          FLUXER_PASSKEY_ADDITIONAL_ALLOWED_ORIGINS=https://${secret."fluxer/domain"}
          FLUXER_GATEWAY_RPC_AUTH_TOKEN=${secret."fluxer/gateway_rpc_auth_token"}
          FLUXER_ERLANG_COOKIE=${secret."fluxer/erlang_cookie"}
          FLUXER_MEDIA_PROXY_SECRET_KEY=${secret."fluxer/media_proxy_secret_key"}
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SECRET_BASE64=${secret."fluxer/media_proxy_upload_relay_secret"}
          FLUXER_ADMIN_SECRET_KEY_BASE=${secret."fluxer/admin_secret_key_base"}
          FLUXER_ADMIN_OAUTH_CLIENT_SECRET=${secret."fluxer/admin_oauth_client_secret"}
          FLUXER_INTERNAL_API_ENDPOINT=http://api:8080
          FLUXER_INTERNAL_MEDIA_PROXY_ENDPOINT=http://media-proxy:8080
          FLUXER_APP_ENDPOINT=https://${secret."fluxer/domain"}
          FLUXER_ADMIN_ENDPOINT=https://${secret."fluxer/domain"}/admin
          FLUXER_MARKETING_ENDPOINT=https://${secret."fluxer/domain"}
          FLUXER_MEDIA_ENDPOINT=https://${secret."fluxer/domain"}/media
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT=https://${secret."fluxer/domain"}/media
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_ENDPOINT=https://${secret."fluxer/domain"}/media
          FLUXER_STATIC_CDN_ENDPOINT=https://${secret."fluxer/domain"}
          POSTGRES_DB=fluxer
          POSTGRES_USER=fluxer
          POSTGRES_PASSWORD=${secret."fluxer/postgres_password"}
          MEILI_ENV=production
          MEILI_NO_ANALYTICS=true
          MEILI_LOG_LEVEL=WARN
          MEILI_MAX_INDEXING_MEMORY=256mb
          MEILI_MAX_INDEXING_THREADS=2
          MEILI_MASTER_KEY=${secret."fluxer/meili_master_key"}
          LIVEKIT_KEYS=fluxer: ${secret."fluxer/livekit_api_secret"}
        '';
      };
      sops.templates."fluxer-livekit-yaml" = {
        content = ''
          port: 7880
          log_level: info

          rtc:
            tcp_port: 7881
            udp_port: 7882
            node_ip: "${secret."fluxer/livekit_node_ip"}"
            use_external_ip: false
            stun_servers:
              - stun.l.google.com:19302
              - stun1.l.google.com:19302

          webhook:
            api_key: fluxer
            urls:
              - http://api:8080/webhooks/livekit
        '';
      };
      virtualisation.oci-containers.containers."fluxer-admin" = {
        image = "ghcr.io/fluxerapp/fluxer-admin@sha256:6f9ff0a1a371df16e09dee50060d82f773ba697dc208024c582701c9f0468ca1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_ADMIN_BASE_PATH = "/admin";
          FLUXER_ADMIN_PORT = "8080";
          FLUXER_API_ENDPOINT = "http://api:8080";
          FLUXER_STATIC_CDN_ENDPOINT = "https://${domain}";
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-api"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcAdmin}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--network-alias=admin"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-api" = {
        image = "ghcr.io/fluxerapp/fluxer-api@sha256:77770cc0bbde530f9a49cc20d0f8ef981083bac482efcb3346e61ddd86a9e790";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_API_PORT = "8080";
          FLUXER_SETUP_TOKEN = "";
          FLUXER_API_PRESIGNED_ATTACHMENT_UPLOADS_ENABLED = "true";
          FLUXER_API_EMBEDDED_WORKER = "false";
          FLUXER_POSTGRES_MAX_CONNECTIONS = "25";
          NODE_OPTIONS = "--max-old-space-size-percentage=60";
          NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
        };
        dependsOn = [
          "fluxer-gifs"
          "fluxer-meilisearch"
          "fluxer-messages"
          "fluxer-nats"
          "fluxer-postgres"
          "fluxer-seaweedfs-init"
          "fluxer-snowflakes"
          "fluxer-users"
          "fluxer-valkey"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcApi}"
          "--health-interval=10s"
          "--health-retries=30"
          "--health-start-period=1m30s"
          "--health-timeout=5s"
          "--network-alias=api"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-app-proxy" = {
        image = "ghcr.io/fluxerapp/fluxer-app-proxy-self-hosted@sha256:1473a77cc75f3bdbd395a2f83abb0019c95c323ddbbead00feb7a55bdf5dd841";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          DISCOVERY_REFRESH_INTERVAL_MS = "5000";
          DISCOVERY_UPSTREAM_URL = "http://edge:8088/.well-known/fluxer";
          FLUXER_APP_PROXY_PORT = "8080";
          FLUXER_LIVEKIT_URL = "https://${domain}/livekit";
          FLUXER_MEDIA_ENDPOINT = "https://${domain}/media";
          FLUXER_S3_BUCKET_UPLOADS = "fluxer-uploads";
          FLUXER_S3_PUBLIC_ENDPOINT = "http://seaweedfs:8333";
          FLUXER_STATIC_CDN_ENDPOINT = "https://${domain}";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-api"
          "fluxer-edge"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcCurl "http://127.0.0.1:8080/_ready"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=app-proxy"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-edge" = {
        image = "docker.io/library/caddy:2.11-alpine";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_ADMIN_BASE_PATH = "/admin";
          FLUXER_EDGE_ENCODE = "zstd gzip";
          FLUXER_EDGE_PROTOCOLS = "h1 h2";
          FLUXER_EDGE_SITE_ADDRESS = ":80";
          FLUXER_EDGE_TRUSTED_PROXIES = "private_ranges";
        };
        volumes = [
          "${caddyfile}:/etc/caddy/Caddyfile:ro"
          "fluxer_edge-config:/config:rw"
          "fluxer_edge-data:/data:rw"
        ];
        ports = [
          "8092:80/tcp"
        ];
        dependsOn = [
          "fluxer-admin"
          "fluxer-api"
          "fluxer-gateway"
          "fluxer-media-proxy"
          "fluxer-static-proxy"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:2019/config/"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=edge"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-gateway" = {
        image = "ghcr.io/fluxerapp/fluxer-gateway@sha256:e86d1679d672823a7e6bc203f8da1fbcf7357089a05809f37f879b7eb6d2b0f2";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_ERLANG_SCHEDULERS_MAX = "16";
          FLUXER_ERLANG_SCHEDULERS_MIN = "2";
          FLUXER_GATEWAY_LOGGER_LEVEL = "info";
          FLUXER_GATEWAY_MEDIA_PROXY_ENDPOINT = "https://${domain}/media";
          FLUXER_GATEWAY_PORT = "8080";
          FLUXER_GATEWAY_STATIC_CDN_ENDPOINT = "https://${domain}";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-valkey"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcGateway}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=90s"
          "--network-alias=gateway"
          "--network=fluxer_fluxer"
          "--ulimit=nofile=65536:65536"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-gifs" = {
        image = "ghcr.io/fluxerapp/fluxer-gifs@sha256:e01416fdcc46907abd8ce50b311e05822927c13c13e99c38984951c7c2933fbb";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_GIFS_SHARD_CACHE_MAX_BYTES = "134217728";
          FLUXER_SVC_MODE = "combined";
          FLUXER_SVC_NAME = "gifs";
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcSvc}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--stop-timeout=30"
          "--network-alias=gifs"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-livekit" = {
        image = "docker.io/livekit/livekit-server:v1.12.0";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        volumes = [
          "${config.sops.templates."fluxer-livekit-yaml".path}:/etc/livekit.yaml:ro"
        ];
        ports = [
          "7881:7881/tcp"
          "7882:7882/udp"
        ];
        cmd = [
          "--config"
          "/etc/livekit.yaml"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:7880/"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=livekit"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-media-proxy" = {
        image = "ghcr.io/fluxerapp/fluxer-media-proxy@sha256:7db3e5702b2167fac51ed93a68f57270e4573f39c8bc0c9c791e51bc4cb087c1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_CORS_ALLOWED_ORIGINS = "https://${domain}";
          FLUXER_MEDIA_PROXY_HOST = "0.0.0.0";
          FLUXER_MEDIA_PROXY_MODE = "upload";
          FLUXER_MEDIA_PROXY_PORT = "8080";
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_MEDIA_PROXY_STORAGE_BACKEND = "s3";
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SPOOL_MAX_TOTAL_BYTES = "2147483648";
          FLUXER_S3_READ_SIGNED = "true";
          TOKIO_WORKER_THREADS = "4";
        };
        volumes = [
          "fluxer_media-proxy-tmp:/tmp:rw"
        ];
        dependsOn = [
          "fluxer-nats"
          "fluxer-seaweedfs-init"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${
            hcExec [
              "/usr/local/bin/fluxer-media-proxy"
              "healthcheck"
            ]
          }"
          "--health-interval=30s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=media-proxy"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-push" = {
        image = "ghcr.io/fluxerapp/fluxer-push@sha256:ae2bd2ef4309b98f3c221cf2a19c2b04dcbfa32f8229c94ffe550606b0f358e2";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-api"
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${
            hcExec [
              "/usr/local/bin/fluxer-push"
              "healthcheck"
            ]
          }"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--network-alias=push"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-meilisearch" = {
        image = "docker.io/getmeili/meilisearch:v1.53";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          MEILI_UPGRADE_DB = "true";
          MEILI_MAX_INDEXING_THREADS = "2";
        };
        volumes = [
          "fluxer_meilisearch-data:/meili_data:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:7700/health"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=meilisearch"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-messages" = {
        image = "ghcr.io/fluxerapp/fluxer-messages@sha256:61b36a65b81295d665b1f4ff71f0cb8f9b1bc91bd47852709c7e1c650fb85d32";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_POSTGRES_MAX_CONNECTIONS = "20";
          FLUXER_SVC_MODE = "combined";
          FLUXER_SVC_NAME = "messages";
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-postgres"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcSvc}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--stop-timeout=30"
          "--network-alias=messages"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-nats" = {
        image = "docker.io/library/nats:2.14-alpine";
        environment = {
          FLUXER_NATS_MAX_FILE_STORE = "10GB";
          FLUXER_NATS_MAX_MEMORY_STORE = "64MB";
          GOMEMLIMIT = "200MiB";
        };
        volumes = [
          "fluxer_nats-data:/data:rw"
        ];
        cmd = [
          "sh"
          "-c"
          ''
            printf 'http_port: 8222\njetstream {\n  store_dir: /data\n  max_memory_store: %s\n  max_file_store: %s\n}\n' "$FLUXER_NATS_MAX_MEMORY_STORE" "$FLUXER_NATS_MAX_FILE_STORE" > /tmp/nats.conf && exec nats-server -c /tmp/nats.conf
          ''
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:8222/healthz"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=nats"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-postgres" = {
        image = "docker.io/library/postgres:16-alpine";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        volumes = [
          "fluxer_postgres-data:/var/lib/postgresql/data:rw"
        ];
        cmd = [
          "postgres"
          "-c"
          "max_connections=150"
          "-c"
          "shared_buffers=512MB"
          "-c"
          "effective_cache_size=2GB"
          "-c"
          "work_mem=8MB"
          "-c"
          "maintenance_work_mem=256MB"
          "-c"
          "autovacuum_work_mem=128MB"
          "-c"
          "random_page_cost=1.1"
          "-c"
          "effective_io_concurrency=200"
          "-c"
          "default_statistics_target=200"
          "-c"
          "jit=off"
          "-c"
          "min_wal_size=80MB"
          "-c"
          "max_wal_size=2GB"
          "-c"
          "checkpoint_completion_target=0.9"
          "-c"
          "wal_buffers=16MB"
          "-c"
          "wal_compression=zstd"
          "-c"
          "bgwriter_delay=50ms"
          "-c"
          "bgwriter_lru_maxpages=1000"
          "-c"
          "autovacuum_vacuum_scale_factor=0.05"
          "-c"
          "autovacuum_analyze_scale_factor=0.02"
          "-c"
          "autovacuum_vacuum_cost_limit=2000"
          "-c"
          "autovacuum_max_workers=3"
          "-c"
          "max_parallel_workers_per_gather=2"
          "-c"
          "max_parallel_workers=8"
          "-c"
          "track_io_timing=on"
          "-c"
          "shared_preload_libraries=pg_stat_statements"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${
            hcExec [
              "pg_isready"
              "-U"
              "fluxer"
              "-d"
              "fluxer"
            ]
          }"
          "--health-interval=10s"
          "--health-retries=10"
          "--health-timeout=5s"
          "--network-alias=postgres"
          "--network=fluxer_fluxer"
          "--shm-size=1gb"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-seaweedfs" = {
        image = "docker.io/chrislusf/seaweedfs:4.47";
        environment = {
          GOMEMLIMIT = "1536MiB";
          WEED_MASTER_VOLUME_GROWTH_COPY_1 = "1";
        };
        volumes = [
          "fluxer_seaweedfs-data:/data:rw"
        ];
        cmd = [
          "server"
          "-s3"
          "-s3.iam=false"
          "-dir=/data"
          "-master.telemetry=false"
          "-master.volumeSizeLimitMB=1024"
          "-master.garbageThreshold=0.1"
          "-volume.max=10000"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:8333/healthz"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=20"
          "--health-start-period=60s"
          "--network-alias=seaweedfs"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-seaweedfs-init" = {
        image = "docker.io/chrislusf/seaweedfs:4.47";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        dependsOn = [
          "fluxer-seaweedfs"
        ];
        log-driver = "journald";
        extraOptions = [
          "--entrypoint=${seaweedfsInitEntrypoint}"
          "--network-alias=seaweedfs-init"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-snowflakes" = {
        image = "ghcr.io/fluxerapp/fluxer-snowflakes@sha256:f8cdb14a6b75317e4dcfc171fc8efc2463080fc7c8908899284ed4378152892b";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_SVC_MODE = "combined";
          FLUXER_SVC_NAME = "snowflakes";
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcSvc}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--stop-timeout=30"
          "--network-alias=snowflakes"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-static-proxy" = {
        image = "ghcr.io/fluxerapp/fluxer-static@sha256:aaf8c46fed98b2751e1354e7dba56780652071e24d4d65876a32bcf0aadb5301";
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:8080/avatars/0.png"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--health-start-period=60s"
          "--network-alias=static-proxy"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-unfurl" = {
        image = "ghcr.io/fluxerapp/fluxer-unfurl@sha256:809e115b6b5aaa552d8961f839be484268d495917952c5828ee1cb7f2b2e8ae7";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_ENDPOINT = "http://media-proxy:8080";
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_STATIC_CDN_ENDPOINT = "https://${domain}";
          FLUXER_SVC_MODE = "combined";
          FLUXER_SVC_NAME = "unfurl";
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcSvc}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--stop-timeout=30"
          "--network-alias=unfurl"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-users" = {
        image = "ghcr.io/fluxerapp/fluxer-users@sha256:05d517983c0962a1af898634029b4a4bbc8024f7cce09c7dd075aa12d7b13c96";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_POSTGRES_MAX_CONNECTIONS = "20";
          FLUXER_SVC_MODE = "combined";
          FLUXER_SVC_NAME = "users";
          MALLOC_ARENA_MAX = "2";
          TOKIO_WORKER_THREADS = "2";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-postgres"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcSvc}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=30"
          "--health-start-period=60s"
          "--stop-timeout=30"
          "--network-alias=users"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-valkey" = {
        image = "docker.io/valkey/valkey:9.1-alpine";
        volumes = [
          "fluxer_valkey-data:/data:rw"
        ];
        cmd = [
          "valkey-server"
          "--appendonly"
          "yes"
          "--appendfsync"
          "everysec"
          "--dir"
          "/data"
          "--save"
          ""
          "--maxmemory"
          "192mb"
          "--maxmemory-policy"
          "noeviction"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${
            hcExec [
              "valkey-cli"
              "ping"
            ]
          }"
          "--health-interval=10s"
          "--health-retries=10"
          "--health-timeout=5s"
          "--health-start-period=60s"
          "--network-alias=valkey"
          "--network=fluxer_fluxer"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-worker" = {
        image = "ghcr.io/fluxerapp/fluxer-api@sha256:77770cc0bbde530f9a49cc20d0f8ef981083bac482efcb3346e61ddd86a9e790";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_API_WORKER_ENABLE_CRON_SCHEDULER = "true";
          FLUXER_API_WORKER_MODE = "all_lanes";
          FLUXER_POSTGRES_MAX_CONNECTIONS = "25";
          FLUXER_WORKER_POSTGRES_SYNCHRONOUS_COMMIT = "";
          NODE_OPTIONS = "--max-old-space-size-percentage=55";
          NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
        };
        cmd = [
          "node"
          "dist/WorkerEntrypoint.js"
        ];
        dependsOn = [
          "fluxer-messages"
          "fluxer-nats"
          "fluxer-postgres"
          "fluxer-seaweedfs-init"
          "fluxer-snowflakes"
          "fluxer-users"
          "fluxer-valkey"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWorker}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=3"
          "--health-start-period=90s"
          "--network-alias=worker"
          "--network=fluxer_fluxer"
        ];
      };
      # Networks + volumes + per-container units.
      # The network oneshot is special-cased (it owns the ExecStop teardown);
      # containers use identical wiring to the compose network plus any named
      # volumes they bind, so they are generated from the wiring table.
      systemd.services =
        let
          network = {
            "podman-network-fluxer_fluxer" = {
              path = [ pkgs.podman ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStop = "podman network rm -f fluxer_fluxer";
              };
              script = ''
                podman network inspect fluxer_fluxer || podman network create fluxer_fluxer --driver=bridge
              '';
              partOf = [ "podman-compose-fluxer-root.target" ];
              wantedBy = [ "podman-compose-fluxer-root.target" ];
            };
          };
        in
        builtins.foldl' lib.recursiveUpdate network (
          map volumeService fluxerVolumes
          ++ map (name: podmanService name serviceWiring.${name}) (builtins.attrNames serviceWiring)
        );

      # Root service
      # When started, this will automatically create all resources and start
      # the containers. When stopped, this will teardown all resources.
      systemd.targets."podman-compose-fluxer-root" = {
        unitConfig = {
          Description = "Root target generated by compose2nix.";
        };
        wantedBy = [ "multi-user.target" ];
      };
    };
}
