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
          8443
        ];
        allowedUDPPorts = [ 7882 ];
      };
      services.tailscale.permitCertUid = lib.mkIf config.services.caddy.enable config.services.caddy.user;
      services.tailscale.useRoutingFeatures = "client";
      services.caddy = {
        enable = true;
        httpsPort = 8443;
        virtualHosts = {
          "media.lain".extraConfig = ''
            tls internal {
              on_demand
            }
            reverse_proxy 127.0.0.1:8096
          '';

          "qbit.lain".extraConfig = ''
            tls internal {
              on_demand
            }
            reverse_proxy 127.0.0.1:8080
          '';
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
