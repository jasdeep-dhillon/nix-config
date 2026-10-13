{ self, ... }:
{
  flake.nixosModules.desktop =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = with self.nixosModules; [
        niri
        flatpak
        fonts
        scheduler
        jellyfin-client
        input-share
        guiPrograms
      ];
      systemd.user.services.tailscale-systray = {
        enable = true;
        requires = [ "dbus.service" ];
        partOf = [
          "default.target"
          "graphical-session.target"
        ];
        after = [
          "dbus.target"
          "graphical-session.target"
        ];
        wantedBy = [
          "default.target"
          "graphical-session.target"
        ];
        description = "Tailscale system tray";
        serviceConfig = {
          Type = "simple";
          Restart = "on-abort";
          ExecStart = "${lib.getExe config.services.tailscale.package} systray";
        };
      };

      # Ports for KDE Connect
      networking.firewall = {
        allowedTCPPorts = (lib.lists.range 1714 1764);
        allowedUDPPorts = (lib.lists.range 1714 1764);
      };

      # auto mount service
      services.gvfs.enable = true;
      services.udev.packages = [ pkgs.libmtp ];
      home-manager.users.arc = {
        imports = [ self.homeModules.desktop ];
      };
    };

  flake.homeModules.desktop = {
    imports = with self.homeModules; [
      shortcuts
      theme
      browser
    ];
    services.kdeconnect.enable = true;
  };
}
