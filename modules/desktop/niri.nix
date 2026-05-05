{ self, ... }:
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      imports = with self.nixosModules; [
        sddm
        window-manager
        theme
      ];
      environment.systemPackages = with pkgs; [
        seahorse
      ];
      security.pam.services.hyprlock = { };
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
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          kdePackages.xdg-desktop-portal-kde
        ];
        configPackages = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
        config.common = {
          default = [ "gnome" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
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
