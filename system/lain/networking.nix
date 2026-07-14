{ ... }:
{
  flake.nixosModules.lain =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      caddyWithPlugin = pkgs.caddy.withPlugins {
        plugins = [ "github.com/tailscale/caddy-tailscale@v0.0.0-20260106222316-bb080c4414ac" ];
        hash = "sha256-vC/nyCKMD2jKgbGVA5NIJP6dGXiP9z0yEA8WINgFcVc=";
      };
      caddyImage = pkgs.dockerTools.buildImage {
        name = "caddy-tailscale";
        tag = "latest";
        copyToRoot = [ caddyWithPlugin ];
        config = {
          Entrypoint = [ "${caddyWithPlugin}/bin/caddy" "run" "--config" "/etc/caddy/Caddyfile" "--adapter" "caddyfile" ];
        };
      };
      caddyfile = pkgs.writeText "Caddyfile" ''
        {
          auto_https off
        }

        :8443 {
          @fluxer host lain.tailc113f2.ts.net
          handle @fluxer {
            reverse_proxy 127.0.0.1:8092
          }

          handle {
            reverse_proxy 127.0.0.1:8092
          }
        }

        media.tailc113f2.ts.net {
          bind tailscale/media
          tls {
            get_certificate tailscale
          }
          reverse_proxy 127.0.0.1:8096
        }

        qbit.tailc113f2.ts.net {
          bind tailscale/qbit
          tls {
            get_certificate tailscale
          }
          reverse_proxy 127.0.0.1:8098
        }
      '';
    in
    {
      networking.networkmanager.enable = true;
      networking.hostName = "lain";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          443
          7881
          8443
        ];
        allowedUDPPorts = [ 7882 ];
      };
      services.tailscale.useRoutingFeatures = "client";

      sops.templates."caddy-env" = {
        content = "TS_AUTHKEY=${config.sops.placeholder."private_keys/tailscale"}";
        mode = "0440";
        owner = "root";
      };

      virtualisation.podman.enable = true;
      virtualisation.oci-containers.containers.caddy = {
        image = "caddy-tailscale:latest";
        volumes = [
          "${caddyfile}:/etc/caddy/Caddyfile:ro"
          "caddy-config:/var/lib/caddy/.config:rw"
        ];
        environmentFiles = [ config.sops.templates."caddy-env".path ];
        environment = {
          HOME = "/var/lib/caddy";
        };
        extraOptions = [
          "--network=host"
          "--mount=type=bind,source=/var/run/tailscale,target=/var/run/tailscale,readonly"
        ];
      };

      systemd.services."podman-caddy".preStart = lib.mkForce ''
        ${pkgs.podman}/bin/podman load -i ${caddyImage}
      '';

      systemd.services.tailscale-funnel = {
        description = "Tailscale Funnel for Caddy";
        after = [
          "tailscaled.service"
          "network-online.target"
          "podman-caddy.service"
        ];
        wants = [
          "tailscaled.service"
          "network-online.target"
          "podman-caddy.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --bg --https=443 8443";
          ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --https=443 off";
        };
      };
    };
}
