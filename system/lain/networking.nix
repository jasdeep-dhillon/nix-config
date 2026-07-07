{ ... }:
{
  flake.nixosModules.lain =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      networking.networkmanager.enable = true;
      networking.hostName = "lain";
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          80
          443
          7881
        ];
        allowedUDPPorts = [ 7882 ];
      };
      services.tailscale.permitCertUid = lib.mkIf config.services.caddy.enable config.services.caddy.user;
      services.tailscale.useRoutingFeatures = "client";
      services.caddy = {
        enable = true;
        virtualHosts = {
          "media.lain.home".extraConfig = ''
            tls internal {
              on_demand
            }
            reverse_proxy 127.0.0.1:8096
          '';

          "qbit.lain.home".extraConfig = ''
            tls internal {
              on_demand
            }
            reverse_proxy 127.0.0.1:8080
          '';

          # "fluxer.lain.home".extraConfig = ''
          #   tls internal {
          #     on_demand
          #   }
          #   reverse_proxy 127.0.0.1:8092
          # '';

          # "lain.tailc113f2.ts.net".extraConfig = ''
          #   tls /var/lib/tailscale/certs/lain.tailc113f2.ts.net.crt /var/lib/tailscale/certs/lain.tailc113f2.ts.net.key
          #   reverse_proxy 127.0.0.1:8092
          # '';

          # "qbit.lain.tailc113f2.ts.net".extraConfig = ''
          #   tls /var/lib/tailscale/certs/lain.tailc113f2.ts.net.crt /var/lib/tailscale/certs/lain.tailc113f2.ts.net.key
          #   reverse_proxy 127.0.0.1:8080
          # '';
        };
      };

      systemd.services.tailscale-funnel = {
        description = "Tailscale Funnel to host fluxer server";
        after = [
          "tailscaled.service"
          "network-online.target"
          "podman-fluxer-caddy.service"
        ];
        wants = [
          "tailscaled.service"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.tailscale}/bin/tailscale funnel --bg --https=443 8092";
          ExecStop = "${pkgs.tailscale}/bin/tailscale funnel --https=443 off";
        };
      };
    };
}
