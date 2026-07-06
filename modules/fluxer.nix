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
      inherit (config.sops) placeholder;
      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          servers {
            trusted_proxies static private_ranges
          }
        }

        {''$FLUXER_CADDY_SITE_ADDRESS} {
          encode zstd gzip

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

          handle /livekit {
            reverse_proxy livekit:7880
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

          @staticAssets path /fonts/* /web/* /emoji/* /libs/* /avatars/* /badges/* /desktop/* /embeds/*
          handle @staticAssets {
            reverse_proxy static-proxy:8080
          }

          handle {
            reverse_proxy app-proxy:8080
          }
        }

        :8088 {
          handle_path /api/* {
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
          use_external_ip: false
          stun_servers:
            - stun.l.google.com:19302
            - stun1.l.google.com:19302

        webhook:
          api_key: fluxer
          urls:
            - http://api:8080/webhooks/livekit
      '';
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
          FLUXER_SELF_HOSTED=true
          FLUXER_BASE_DOMAIN=${placeholder."fluxer/domain"}
          FLUXER_PUBLIC_SCHEME=https
          FLUXER_PUBLIC_PORT=443
          FLUXER_TRUST_CLIENT_IP_HEADER=true
          FLUXER_CLIENT_IP_HEADER_NAME=x-forwarded-for
          FLUXER_DATABASE_BACKEND=postgres
          FLUXER_POSTGRES_HOST=postgres
          FLUXER_POSTGRES_PORT=5432
          FLUXER_POSTGRES_DATABASE=fluxer
          FLUXER_POSTGRES_USERNAME=fluxer
          FLUXER_POSTGRES_PASSWORD=${placeholder."fluxer/postgres_password"}
          FLUXER_POSTGRES_SSL=false
          FLUXER_KV_URL=redis://valkey:6379/0
          FLUXER_NATS_URL=nats://nats:4222
          FLUXER_NATS_JETSTREAM_URL=nats://nats:4222
          FLUXER_SVC_NATS_URL=nats://nats:4222
          FLUXER_SVC_SHARD_COUNT=1
          FLUXER_SEARCH_ENGINE=meilisearch
          FLUXER_SEARCH_URL=http://meilisearch:7700
          FLUXER_SEARCH_API_KEY=${placeholder."fluxer/meili_master_key"}
          FLUXER_S3_ENDPOINT=http://seaweedfs:8333
          FLUXER_S3_PUBLIC_ENDPOINT=http://seaweedfs:8333
          FLUXER_S3_REGION=us-east-1
          FLUXER_S3_ACCESS_KEY_ID=fluxer
          FLUXER_S3_SECRET_ACCESS_KEY=${placeholder."fluxer/s3_secret_key"}
          FLUXER_S3_FORCE_PATH_STYLE=true
          FLUXER_S3_BUCKET_CDN=fluxer
          FLUXER_S3_BUCKET_UPLOADS=fluxer-uploads
          FLUXER_S3_BUCKET_DOWNLOADS=fluxer-downloads
          FLUXER_S3_BUCKET_REPORTS=fluxer-reports
          FLUXER_S3_BUCKET_HARVESTS=fluxer-harvests
          AWS_ACCESS_KEY_ID=fluxer
          AWS_SECRET_ACCESS_KEY=${placeholder."fluxer/s3_secret_key"}
          AWS_DEFAULT_REGION=us-east-1
          AWS_EC2_METADATA_DISABLED=true
          FLUXER_LIVEKIT_ENABLED=true
          FLUXER_LIVEKIT_API_KEY=fluxer
          FLUXER_LIVEKIT_API_SECRET=${placeholder."fluxer/livekit_api_secret"}
          FLUXER_LIVEKIT_URL=https://${placeholder."fluxer/domain"}/livekit
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
          FLUXER_SUDO_MODE_SECRET=${placeholder."fluxer/sudo_mode_secret"}
          FLUXER_CONNECTION_INITIATION_SECRET=${placeholder."fluxer/connection_initiation_secret"}
          FLUXER_VAPID_PUBLIC_KEY=BLFtEENtXI2kDpLjP92GTmi8uSOJscnc13KBhdA2WtYFbXpK5kYuGEfskOzo9qRaVh5rTBLSWbE1svabHZC9Qds
          FLUXER_VAPID_PRIVATE_KEY=${placeholder."fluxer/vapid_private_key"}
          FLUXER_VAPID_EMAIL=admin@example.com
          FLUXER_GATEWAY_RPC_AUTH_TOKEN=${placeholder."fluxer/gateway_rpc_auth_token"}
          FLUXER_MEDIA_PROXY_SECRET_KEY=${placeholder."fluxer/media_proxy_secret_key"}
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SECRET_BASE64=${
            placeholder."fluxer/media_proxy_upload_relay_secret"
          }
          FLUXER_ADMIN_SECRET_KEY_BASE=${placeholder."fluxer/admin_secret_key_base"}
          FLUXER_ADMIN_OAUTH_CLIENT_SECRET=${placeholder."fluxer/admin_oauth_client_secret"}
          FLUXER_INTERNAL_API_ENDPOINT=http://api:8080
          FLUXER_INTERNAL_GATEWAY_ENDPOINT=http://gateway:8080
          FLUXER_INTERNAL_MEDIA_PROXY_ENDPOINT=http://media-proxy:8080
          FLUXER_MARKETING_ENDPOINT=https://${placeholder."fluxer/domain"}
          FLUXER_MEDIA_PROXY_ENDPOINT=http://media-proxy:8080
          FLUXER_MEDIA_ENDPOINT=https://${placeholder."fluxer/domain"}/media
          FLUXER_MEDIA_PROXY_UPLOAD_RELAY_ENDPOINT=https://${placeholder."fluxer/domain"}/media
          POSTGRES_DB=fluxer
          POSTGRES_USER=fluxer
          POSTGRES_PASSWORD=${placeholder."fluxer/postgres_password"}
          MEILI_ENV=production
          MEILI_NO_ANALYTICS=true
          MEILI_MASTER_KEY=${placeholder."fluxer/meili_master_key"}
          LIVEKIT_KEYS=fluxer: ${placeholder."fluxer/livekit_api_secret"}
          NODE_IP=${placeholder."fluxer/livekit_node_ip"}
        '';
      };
      virtualisation.oci-containers.containers."fluxer-admin" = {
        image = "ghcr.io/fluxerapp/fluxer-admin:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_ADMIN_BASE_PATH = "/admin";
          FLUXER_ADMIN_ENDPOINT = "https://fluxer.lain.home/admin";
          FLUXER_ADMIN_HOST = "0.0.0.0";
          FLUXER_ADMIN_OAUTH_REDIRECT_URI = "https://fluxer.lain.home/admin/oauth2_callback";
          FLUXER_ADMIN_PORT = "8080";
          FLUXER_API_ENDPOINT = "http://api:8080";
          FLUXER_APP_ENDPOINT = "https://fluxer.lain.home";
          FLUXER_STATIC_CDN_ENDPOINT = "https://fluxer.lain.home";
        };
        dependsOn = [
          "fluxer-api"
        ];
        log-driver = "journald";
        extraOptions = [
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
          DISCOVERY_UPSTREAM_URL = "http://caddy:8088/api/.well-known/fluxer";
          FLUXER_APP_PROXY_HOST = "0.0.0.0";
          FLUXER_APP_PROXY_PORT = "8080";
          PUBLIC_BOOTSTRAP_API_ENDPOINT = "/api";
          PUBLIC_BOOTSTRAP_API_PUBLIC_ENDPOINT = "https://fluxer.lain.home/api";
        };
        dependsOn = [
          "fluxer-api"
          "fluxer-caddy"
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
      virtualisation.oci-containers.containers."fluxer-caddy" = {
        image = "caddy:2.10-alpine";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_CADDY_SITE_ADDRESS = ":80";
        };
        volumes = [
          "${caddyfile}:/etc/caddy/Caddyfile:ro"
          "fluxer_caddy-config:/config:rw"
          "fluxer_caddy-data:/data:rw"
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
          "--network-alias=caddy"
          "--network=fluxer_fluxer"
        ];
      };
      systemd.services."podman-fluxer-caddy" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_caddy-config.service"
          "podman-volume-fluxer_caddy-data.service"
        ];
        requires = [
          "podman-network-fluxer_fluxer.service"
          "podman-volume-fluxer_caddy-config.service"
          "podman-volume-fluxer_caddy-data.service"
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
          FLUXER_GATEWAY_LOGGER_LEVEL = "info";
          FLUXER_GATEWAY_MEDIA_PROXY_ENDPOINT = "https://fluxer.lain.home/media";
          FLUXER_GATEWAY_PORT = "8080";
          FLUXER_GATEWAY_STATIC_CDN_ENDPOINT = "https://fluxer.lain.home";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-valkey"
        ];
        log-driver = "journald";
        extraOptions = [
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
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://fluxer.lain.home/media";
          FLUXER_SVC_MODE = "router";
          FLUXER_SVC_NAME = "gifs";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
          FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT = "https://fluxer.lain.home/media";
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_NAME = "gifs";
          FLUXER_SVC_SHARD_ID = "0";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
          FLUXER_MEDIA_PROXY_STORAGE_BACKEND = "s3";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-seaweedfs-init"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=media-proxy"
          "--network=fluxer_fluxer"
          "--no-healthcheck"
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
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_SHARD_ID = "0";
        };
        dependsOn = [
          "fluxer-nats"
          "fluxer-postgres"
        ];
        log-driver = "journald";
        extraOptions = [
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
        log-driver = "journald";
        extraOptions = [
          "--health-cmd=pg_isready -U fluxer -d fluxer"
          "--health-interval=10s"
          "--health-retries=10"
          "--health-timeout=5s"
          "--network-alias=postgres"
          "--network=fluxer_fluxer"
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
        cmd = [
          "server"
          "-s3"
          "-dir=/data"
        ];
        log-driver = "journald";
        extraOptions = [
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
        dependsOn = [
          "fluxer-seaweedfs"
        ];
        log-driver = "journald";
        extraOptions = [
          ''--entrypoint=["/bin/sh", "-c", "for i in $(seq 1 60); do echo s3.bucket.create -name fluxer | weed shell -master=seaweedfs:9333 >/dev/null 2>&1 && break || sleep 2; done; for b in fluxer fluxer-uploads fluxer-downloads fluxer-reports fluxer-harvests; do echo s3.bucket.create -name $b | weed shell -master=seaweedfs:9333 || true; done; echo buckets ready"]''
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
          FLUXER_SVC_MODE = "router";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_SHARD_ID = "0";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
          FLUXER_SVC_MODE = "shard";
          FLUXER_SVC_SHARD_ID = "0";
        };
        dependsOn = [
          "fluxer-nats"
        ];
        log-driver = "journald";
        extraOptions = [
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
        cmd = [
          "valkey-server"
          "--save"
          ""
          "--appendonly"
          "no"
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
      virtualisation.oci-containers.containers."fluxer-worker" = {
        image = "ghcr.io/fluxerapp/fluxer-api:v1";
        environmentFiles = [ config.sops.templates."fluxer-env".path ];
        environment = {
          FLUXER_API_WORKER_ENABLE_CRON_SCHEDULER = "true";
          FLUXER_API_WORKER_ENABLE_VOICE_RECONCILIATION = "true";
          FLUXER_API_WORKER_MODE = "all_lanes";
        };
        cmd = [
          "./node_modules/.bin/tsx"
          "src/WorkerEntrypoint.ts"
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
      systemd.services."podman-volume-fluxer_caddy-config" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_caddy-config || podman volume create fluxer_caddy-config
        '';
        partOf = [ "podman-compose-fluxer-root.target" ];
        wantedBy = [ "podman-compose-fluxer-root.target" ];
      };
      systemd.services."podman-volume-fluxer_caddy-data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect fluxer_caddy-data || podman volume create fluxer_caddy-data
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
