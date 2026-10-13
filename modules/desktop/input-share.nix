{ ... }:
{
  flake.nixosModules.input-share =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        lan-mouse
      ];
      networking.firewall.allowedTCPPorts = [ 4242 ];
      networking.firewall.allowedUDPPorts = [ 4242 ];

      systemd.user.services.lan-mouse = {
        description = "lan-mouse software KVM";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.lan-mouse} daemon";
          Restart = "on-failure";
        };
      };
    };
}
