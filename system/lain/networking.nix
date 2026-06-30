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
        ];
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
        };
      };
    };
}
