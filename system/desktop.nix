{ self, inputs, ... }:
{
  flake.nixosModules.desktop =
    { config, lib, ... }:
    {
      imports = with self.nixosModules; [
        niri
        flatpak
        fonts
        scheduler
        inputs.home-manager.nixosModules.default
        self.nixosModules.guiPrograms
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
      home-manager.users.arc = {
        imports = [ self.homeModules.desktop ];
      };
    };

  flake.homeModules.desktop = {
    imports = with self.homeModules; [
      shortcuts
      theme
    ];
    services.kdeconnect.enable = true;
  };
}
