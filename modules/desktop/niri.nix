{ self, ... }:
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      imports = with self.nixosModules; [
        noctalia-greeter
        window-manager
        theme
      ];
      environment.systemPackages = with pkgs; [
        seahorse
      ];
      services.gnome.gnome-keyring.enable = true;
      services.displayManager.defaultSession = "niri";
      services.logind.settings.Login = {
        KillUserProcesses = true;
        IdleActionSec = 1800;
        IdleAction = "suspend-then-hibernate";
      };
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
      };
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config.niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };

      # Niri Nvidia rule
      environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri.json".text = ''
        {
          "rules": [
            {
              "pattern": {
                "feature": "procname",
                "matches": "niri"
              },
              "profile": "niri"
            }
          ],
          "profiles": [
            {
              "name": "niri",
              "settings": [
                {
                  "key": "GLVidHeapReuseRatio",
                  "value": 0
                }
              ]
            }
          ]
        }
      '';
    };
}
