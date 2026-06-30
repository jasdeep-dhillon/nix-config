{ ... }:
{
  flake.nixosModules.lain =
    { config, lib, ... }:
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

          "fluxer.lain.home".extraConfig = ''
            tls internal {
              on_demand
            }
            reverse_proxy 127.0.0.1:8092
          '';

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
    };
}
