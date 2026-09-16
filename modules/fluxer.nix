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

      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          servers {
            trusted_proxies static {$FLUXER_EDGE_TRUSTED_PROXIES:private_ranges}
            trusted_proxies_strict
          }
        }

        {''$FLUXER_EDGE_SITE_ADDRESS} {
          encode zstd gzip

          handle /_health {
            respond "OK" 200
          }

          handle_path /api/* {
            reverse_proxy api:8080
          }

          handle /gateway {
            rewrite * /
            reverse_proxy gateway:8080
          }

          handle_path /gateway/* {
            reverse_proxy gateway:8080
          }

          handle_path /media/* {
            reverse_proxy media-proxy:8080
          }

          handle_path /livekit/* {
            reverse_proxy livekit:7880
          }

          handle /admin {
            rewrite * /
            reverse_proxy admin:8080
          }

          handle_path /admin/* {
            reverse_proxy admin:8080
          }

          @staticAssets path /web/* /emoji/* /libs/* /avatars/* /badges/* /desktop/* /embeds/*
          handle @staticAssets {
            reverse_proxy static-proxy:8080
          }

          handle /.well-known/fluxer {
            reverse_proxy api:8080
          }

          handle {
            reverse_proxy app-proxy:8080
          }
        }

        :8088 {
          handle /.well-known/fluxer {
            reverse_proxy api:8080
          }
        }
      '';
      livekitYaml = pkgs.writeText "livekit.yaml" ''
        port: 7880
        log_level: info

        rtc:
          tcp_port: 7881
          udp_port: 7882
          node_ip: 100.104.114.77
          use_external_ip: false
          stun_servers:
            - stun.l.google.com:19302
            - stun1.l.google.com:19302

        webhook:
          api_key: fluxer
          urls:
            - http://api:8080/webhooks/livekit
      '';

      # Healthchecks (JSON arrays, passed to podman's --health-cmd).
      hcSvc = ''["CMD","bash","-c","exec 3<>/dev/tcp/127.0.0.1/8090 && printf 'GET /_health HTTP/1.0\\r\\n\\r\\n' >&3 && head -n 1 <&3 | grep -q ' 200 '"]'';
      hcAdmin = ''["CMD","bash","-c","exec 3<>/dev/tcp/127.0.0.1/8080 && printf 'GET /_health HTTP/1.0\\r\\n\\r\\n' >&3 && head -n 1 <&3 | grep -q ' 200 '"]'';
      hcWorker = ''["CMD","node","-e","const age=Date.now()-require('node:fs').statSync('/tmp/fluxer-worker-heartbeat').mtimeMs;if(age>30000){console.error('worker heartbeat is '+Math.round(age)+'ms old');process.exit(1)}"]'';
      hcGateway = ''["CMD","curl","-fsS","-o","/dev/null","http://127.0.0.1:8080/_health/ready"]'';
      hcWget = url: ''["CMD","wget","-q","-O","/dev/null","${url}"]'';

      seaweedfsInitEntrypoint = builtins.toJSON [
        "/bin/sh"
        "-c"
        ''
          buckets="$FLUXER_S3_BUCKET_CDN $FLUXER_S3_BUCKET_UPLOADS $FLUXER_S3_BUCKET_DOWNLOADS $FLUXER_S3_BUCKET_REPORTS $FLUXER_S3_BUCKET_HARVESTS";
          missing="$buckets";
          for attempt in $(seq 1 60); do
            if ! nc -z seaweedfs 9333 2>/dev/null; then
              sleep 2;
              continue;
            fi;
            listed=$(echo "s3.bucket.list" | timeout 10 weed shell -master=seaweedfs:9333 2>&1);
            missing="";
            for b in $buckets; do
              echo "$listed" | grep -q "^[[:space:]]*$b[[:space:]]" || missing="$''${missing:+$missing }$b";
            done;
            if [ -z "$missing" ]; then
              if ! echo "s3.configure -user=fluxer -access_key=$FLUXER_S3_ACCESS_KEY -secret_key=$FLUXER_S3_SECRET_KEY -actions=Admin,Read,Write,List,Tagging -apply" | timeout 10 weed shell -master=seaweedfs:9333 >/dev/null 2>&1; then
                echo "seaweedfs-init could not configure the S3 identity" >&2;
                exit 1;
              fi;
              echo "buckets ready";
              exit 0;
            fi;
            for b in $missing; do
              echo "s3.bucket.create -name $b" | timeout 10 weed shell -master=seaweedfs:9333 >/dev/null 2>&1;
            done;
            sleep 2;
          done;
          echo "seaweedfs-init could not verify buckets: $missing" >&2;
          exit 1;
        ''
      ];
    in
    {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
      };
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
          NODE_ENV=production
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
          FLUXER_S3_BUCKET_DOWNLOADS=fluxer-downloads
          FLUXER_S3_BUCKET_REPORTS=fluxer-reports
          FLUXER_S3_BUCKET_HARVESTS=fluxer-harvests
          AWS_ACCESS_KEY_ID=fluxer
          AWS_SECRET_ACCESS_KEY=${secret."fluxer/s3_secret_key"}
          AWS_DEFAULT_REGION=us-east-1
          AWS_EC2_METADATA_DISABLED=true
          FLUXER_LIVEKIT_ENABLED=true
          FLUXER_LIVEKIT_API_KEY=fluxer
          FLUXER_LIVEKIT_API_SECRET=${secret."fluxer/livekit_api_secret"}
          FLUXER_LIVEKIT_INTERNAL_URL=http://livekit:7880
          FLUXER_LIVEKIT_URL=https://${secret."fluxer/domain"}/livekit
          FLUXER_LIVEKIT_WEBHOOK_URL=http://api:8080/webhooks/livekit
          FLUXER_LIVEKIT_DEFAULT_REGION={"id":"default","name":"Default","emoji":"🌍","latitude":0,"longitude":0}
          FLUXER_KLIPY_API_KEY=
          FLUXER_EMAIL_ENABLED=false
          FLUXER_EMAIL_PROVIDER=none
          FLUXER_EMAIL_FROM_EMAIL=noreply@example.com
          FLUXER_EMAIL_FROM_NAME=Fluxer
          FLUXER_EMAIL_SMTP_HOST=
          FLUXER_EMAIL_SMTP_PORT=587
          FLUXER_EMAIL_SMTP_USERNAME=
          FLUXER_EMAIL_SMTP_PASSWORD=
          FLUXER_EMAIL_SMTP_SECURE=true
          FLUXER_SMS_ENABLED=false
          FLUXER_CAPTCHA_ENABLED=false
          FLUXER_CAPTCHA_PROVIDER=none
          FLUXER_STRIPE_ENABLED=false
          FLUXER_NCMEC_ENABLED=false
          FLUXER_CLAMAV_ENABLED=false
          FLUXER_DISCOVERY_ENABLED=true
          FLUXER_SUDO_MODE_SECRET=${secret."fluxer/sudo_mode_secret"}
          FLUXER_CONNECTION_INITIATION_SECRET=${secret."fluxer/connection_initiation_secret"}
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
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SECRET_BASE64=${
            secret."fluxer/media_proxy_upload_relay_secret"
          }
          FLUXER_ADMIN_SECRET_KEY_BASE=${secret."fluxer/admin_secret_key_base"}
          FLUXER_ADMIN_OAUTH_CLIENT_SECRET=${secret."fluxer/admin_oauth_client_secret"}
          FLUXER_INTERNAL_API_ENDPOINT=http://api:8080
          FLUXER_INTERNAL_GATEWAY_ENDPOINT=http://gateway:8080
          FLUXER_INTERNAL_MEDIA_PROXY_ENDPOINT=http://media-proxy:8080
          FLUXER_MARKETING_ENDPOINT=https://${secret."fluxer/domain"}
          FLUXER_MEDIA_PROXY_ENDPOINT=http://media-proxy:8080
          FLUXER_MEDIA_ENDPOINT=https://${secret."fluxer/domain"}/media
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_ENDPOINT=https://${secret."fluxer/domain"}/media
          POSTGRES_DB=fluxer
          POSTGRES_USER=fluxer
          POSTGRES_PASSWORD=${secret."fluxer/postgres_password"}
          MEILI_ENV=production
          MEILI_NO_ANALYTICS=true
          MEILI_MAX_INDEXING_MEMORY=384mb
          MEILI_MASTER_KEY=${secret."fluxer/meili_master_key"}
          LIVEKIT_KEYS=fluxer: ${secret."fluxer/livekit_api_secret"}
          NODE_IP=${secret."fluxer/livekit_node_ip"}
        '';
      };
      virtualisation.oci-containers.containers."fluxer-admin" = {
        image = "ghcr.io/fluxerapp/fluxer-admin:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_ADMIN_BASE_PATH = "/admin";
          FLUXER_ADMIN_ENDPOINT = "https://${domain}/admin";
          FLUXER_ADMIN_HOST = "0.0.0.0";
          FLUXER_ADMIN_OAUTH_REDIRECT_URI = "https://${domain}/admin/oauth2_callback";
          FLUXER_ADMIN_PORT = "8080";
          FLUXER_API_ENDPOINT = "http://api:8080";
          FLUXER_APP_ENDPOINT = "https://${domain}";
          FLUXER_MEDIA_ENDPOINT = "https://${domain}/media";
          FLUXER_STATIC_CDN_ENDPOINT = "https://${domain}";
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
      systemd.services."podman-fluxer-admin" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-api" = {
        image = "ghcr.io/fluxerapp/fluxer-api:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_API_PORT = "8080";
          FLUXER_API_PRESIGNED_ATTACHMENT_UPLOADS_ENABLED = "true";
          FLUXER_POSTGRES_MAX_CONNECTIONS = "25";
          NODE_OPTIONS = "--enable-source-maps";
        };
        dependsOn = [
          "fluxer-gifs"
          "fluxer-gifs-shard"
          "fluxer-meilisearch"
          "fluxer-messages"
          "fluxer-messages-shard"
          "fluxer-nats"
          "fluxer-postgres"
          "fluxer-seaweedfs-init"
          "fluxer-snowflakes"
          "fluxer-snowflakes-shard"
          "fluxer-users"
          "fluxer-users-shard"
          "fluxer-valkey"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=node -e \"fetch('http://127.0.0.1:8080/_health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))\""
          "--health-interval=10s"
          "--health-retries=30"
          "--health-start-period=1m30s"
          "--health-timeout=5s"
          "--network-alias=api"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-api" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-app-proxy" = {
        image = "ghcr.io/fluxerapp/fluxer-app-proxy-self-hosted:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          DISCOVERY_UPSTREAM_URL = "http://edge:8088/.well-known/fluxer";
          FLUXER_APP_PROXY_HOST = "0.0.0.0";
          FLUXER_APP_PROXY_PORT = "8080";
          FLUXER_BASE_DOMAIN = "${domain}";
          FLUXER_PUBLIC_ORIGIN = "";
          FLUXER_PUBLIC_PORT = "443";
          FLUXER_PUBLIC_SCHEME = "https";
          PUBLIC_BOOTSTRAP_API_ENDPOINT = "/api";
          PUBLIC_BOOTSTRAP_API_PUBLIC_ENDPOINT = "https://${domain}/api";
        };
        dependsOn = [
          "fluxer-api"
          "fluxer-edge"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=app-proxy"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-app-proxy" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-edge" = {
        image = "caddy:2.10-alpine";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
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
          "--network-alias=edge"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-edge" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_edge-config.service"
          "podman-volume-fluxer_edge-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_edge-config.service"
          "podman-volume-fluxer_edge-data.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-gateway" = {
        image = "ghcr.io/fluxerapp/fluxer-gateway:v1";
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
        ];
      };
      systemd.services."podman-fluxer-gateway" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-gifs" = {
        image = "ghcr.io/fluxerapp/fluxer-gifs:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_SVC_MODE = "router";
          FLUXER_SVC_NAME = "gifs";
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
          "--network-alias=gifs"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-gifs" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-gifs-shard" = {
        image = "ghcr.io/fluxerapp/fluxer-gifs:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_NAME = "gifs";
          FLUXER_SVC_SHARD_ID = "0";
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
          "--network-alias=gifs-shard"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-gifs-shard" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-livekit" = {
        image = "livekit/livekit-server:v1.12.0";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        volumes = [
          "${livekitYaml}:/etc/livekit.yaml:ro"
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
          "--network-alias=livekit"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-livekit" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-media-proxy" = {
        image = "ghcr.io/fluxerapp/fluxer-media-proxy:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_HOST = "0.0.0.0";
          FLUXER_MEDIA_PROXY_MODE = "upload";
          FLUXER_MEDIA_PROXY_PORT = "8080";
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_MEDIA_PROXY_STORAGE_BACKEND = "s3";
          FLUXER_S3_READ_SIGNED = "true";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-seaweedfs-init"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=media-proxy"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-media-proxy" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-meilisearch" = {
        image = "getmeili/meilisearch:v1.12";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        volumes = [
          "fluxer_meilisearch-data:/meili_data:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:7700/health"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--network-alias=meilisearch"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-meilisearch" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_meilisearch-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_meilisearch-data.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-messages" = {
        image = "ghcr.io/fluxerapp/fluxer-messages:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_SVC_MODE = "router";
          FLUXER_SVC_MAX_CONCURRENT_REQUESTS = "";
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
          "--network-alias=messages"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-messages" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-messages-shard" = {
        image = "ghcr.io/fluxerapp/fluxer-messages:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_POSTGRES_MAX_CONNECTIONS = "20";
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_MAX_CONCURRENT_REQUESTS = "";
          FLUXER_SVC_SHARD_ID = "0";
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
          "--network-alias=messages-shard"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-messages-shard" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-nats" = {
        image = "nats:2.14-alpine";
        volumes = [
          "fluxer_nats-data:/data:rw"
        ];
        cmd = [
          "-js"
          "-sd"
          "/data"
          "-m"
          "8222"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:8222/healthz"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--network-alias=nats"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-nats" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_nats-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_nats-data.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-postgres" = {
        image = "postgres:16-alpine";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        volumes = [
          "fluxer_postgres-data:/var/lib/postgresql/data:rw"
        ];
        cmd = [
          "postgres"
          "-c" "max_connections=150"
          "-c" "shared_buffers=512MB"
          "-c" "effective_cache_size=2GB"
          "-c" "work_mem=8MB"
          "-c" "maintenance_work_mem=256MB"
          "-c" "autovacuum_work_mem=128MB"
          "-c" "random_page_cost=1.1"
          "-c" "effective_io_concurrency=200"
          "-c" "default_statistics_target=200"
          "-c" "jit=off"
          "-c" "min_wal_size=512MB"
          "-c" "max_wal_size=2GB"
          "-c" "checkpoint_completion_target=0.9"
          "-c" "wal_buffers=16MB"
          "-c" "wal_compression=zstd"
          "-c" "bgwriter_delay=50ms"
          "-c" "bgwriter_lru_maxpages=1000"
          "-c" "autovacuum_vacuum_scale_factor=0.05"
          "-c" "autovacuum_analyze_scale_factor=0.02"
          "-c" "autovacuum_vacuum_cost_limit=2000"
          "-c" "track_io_timing=on"
          "-c" "shared_preload_libraries=pg_stat_statements"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=pg_isready -U fluxer -d fluxer"
          "--health-interval=10s"
          "--health-retries=10"
          "--health-timeout=5s"
          "--network-alias=postgres"
          "--network=fluxer_fluxer"
          "--shm-size=256mb"
        ];
      };
      systemd.services."podman-fluxer-postgres" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_postgres-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_postgres-data.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-seaweedfs" = {
        image = "chrislusf/seaweedfs:4.34";
        volumes = [
          "fluxer_seaweedfs-data:/data:rw"
        ];
        environment = {
          GOMEMLIMIT = "1536MiB";
        };
        cmd = [
          "server"
          "-s3"
          "-dir=/data"
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
      systemd.services."podman-fluxer-seaweedfs" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_seaweedfs-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_seaweedfs-data.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-seaweedfs-init" = {
        image = "chrislusf/seaweedfs:4.34";
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
      systemd.services."podman-fluxer-seaweedfs-init" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "no";
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-snowflakes" = {
        image = "ghcr.io/fluxerapp/fluxer-snowflakes:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_SVC_MODE = "router";
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
          "--network-alias=snowflakes"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-snowflakes" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-snowflakes-shard" = {
        image = "ghcr.io/fluxerapp/fluxer-snowflakes:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_SHARD_ID = "0";
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
          "--network-alias=snowflakes-shard"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-snowflakes-shard" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-static-proxy" = {
        image = "ghcr.io/fluxerapp/fluxer-static:v1";
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=${hcWget "http://127.0.0.1:8080/avatars/0.png"}"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=10"
          "--network-alias=static-proxy"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-static-proxy" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-unfurl" = {
        image = "ghcr.io/fluxerapp/fluxer-unfurl:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_STATIC_CDN_ENDPOINT = "https://${domain}";
          FLUXER_SVC_MODE = "router";
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
          "--network-alias=unfurl"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-unfurl" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-unfurl-shard" = {
        image = "ghcr.io/fluxerapp/fluxer-unfurl:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://${domain}/media";
          FLUXER_STATIC_CDN_ENDPOINT = "https://${domain}";
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_SHARD_ID = "0";
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
          "--network-alias=unfurl-shard"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-unfurl-shard" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-users" = {
        image = "ghcr.io/fluxerapp/fluxer-users:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_SVC_MODE = "router";
          FLUXER_SVC_MAX_CONCURRENT_REQUESTS = "";
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
          "--network-alias=users"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-users" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-users-shard" = {
        image = "ghcr.io/fluxerapp/fluxer-users:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_POSTGRES_MAX_CONNECTIONS = "20";
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_MAX_CONCURRENT_REQUESTS = "";
          FLUXER_SVC_SHARD_ID = "0";
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
          "--network-alias=users-shard"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-users-shard" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-valkey" = {
        image = "valkey/valkey:8.1-alpine";
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
          "--maxmemory"
          "192mb"
          "--maxmemory-policy"
          "noeviction"
        ];
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=[\"valkey-cli\", \"ping\"]"
          "--health-interval=10s"
          "--health-retries=10"
          "--health-timeout=5s"
          "--network-alias=valkey"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-valkey" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_valkey-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_valkey-data.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };
      virtualisation.oci-containers.containers."fluxer-worker" = {
        image = "ghcr.io/fluxerapp/fluxer-api:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        workdir = "/usr/src/app/fluxer_api";
        environment = {
          FLUXER_API_WORKER_ENABLE_CRON_SCHEDULER = "true";
          FLUXER_API_WORKER_ENABLE_VOICE_RECONCILIATION = "true";
          FLUXER_API_WORKER_MODE = "all_lanes";
          FLUXER_POSTGRES_MAX_CONNECTIONS = "25";
          NODE_OPTIONS = "--enable-source-maps";
        };
        cmd = [
          "sh"
          "-c"
          "if [ -f dist/WorkerEntrypoint.js ]; then exec node dist/WorkerEntrypoint.js; else exec ./node_modules/.bin/tsx src/WorkerEntrypoint.ts; fi"
        ];
        dependsOn = [
          "fluxer-messages-shard"
          "fluxer-nats"
          "fluxer-postgres"
          "fluxer-seaweedfs-init"
          "fluxer-snowflakes-shard"
          "fluxer-users-shard"
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
      systemd.services."podman-fluxer-worker" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
        ];
        partOf = [
          "podman-compose-fluxer-root.target"
        ];
        wantedBy = [
          "podman-compose-fluxer-root.target"
        ];
      };

      # Networks
      systemd.services."podman-network-fluxer_fluxer" = {
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

      # Volumes
      systemd.services."podman-volume-fluxer_edge-config" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_edge-config || podman volume create fluxer_edge-config
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_edge-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_edge-data || podman volume create fluxer_edge-data
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_meilisearch-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_meilisearch-data || podman volume create fluxer_meilisearch-data
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_nats-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_nats-data || podman volume create fluxer_nats-data
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_postgres-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_postgres-data || podman volume create fluxer_postgres-data
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_seaweedfs-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_seaweedfs-data || podman volume create fluxer_seaweedfs-data
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_valkey-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_valkey-data || podman volume create fluxer_valkey-data
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };

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