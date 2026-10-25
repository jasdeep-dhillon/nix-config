{ ... }:
{
  flake.nixosModules.tailscale =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {

      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets."private_keys/tailscale".path;
      };
      networking.nftables.enable = true;

      networking.firewall = {
        trustedInterfaces = [ config.services.tailscale.interfaceName ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=nftables" ];

      systemd.services.tailscale-down = {
        description = "Tailscale down before suspend";
        before = [ "sleep.target" ];
        wants = [ "sleep.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe config.services.tailscale.package} down";
        };
      };

      systemd.services.tailscale-up = {
        description = "Tailscale up after resume";
        after = [
          "resume.target"
          "tailscale-down.service"
        ];
        wants = [ "resume.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe config.services.tailscale.package} up";
        };
      };

      networking.networkmanager.dispatcherScripts = [
        {
          source = pkgs.writeShellScript "tailscale-restart-on-netchange" ''
            case "$2" in
              up|down)
                ${lib.getExe config.services.tailscale.package} down
                ${lib.getExe config.services.tailscale.package} up
                ;;
            esac
          '';
        }
      ];

      systemd.network.wait-online.enable = false;
      boot.initrd.systemd.network.wait-online.enable = false;
    };
}
