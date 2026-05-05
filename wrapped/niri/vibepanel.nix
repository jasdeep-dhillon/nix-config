{ self, inputs, ... }:
{
  flake.nixosModules.niriShell =
    { pkgs, lib, ... }:
    {
      extraPackages = [
        inputs.vibepanel.packages.${pkgs.stdenv.hostPlatform.system}.default
        self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
        pkgs.swaybg
        pkgs.ddcutil
      ];
      settings.spawn-at-startup = [
        [
          (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.swayidle)
        ]
        [
          (lib.getExe pkgs.swaybg)
          "-i"
          "${self.wallpaper}"
          "-m"
          "fill"
        ]
        [
          (lib.getExe pkgs.clipse)
          "-listen"
        ]
        [
          (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
        ]
      ];

      settings.switch-events = {
        lid-close = {
          spawn = [ ];
        };
        lid-open = {
          spawn = [ ];
        };
      };
      settings.binds = {
        "Mod+F5" = _: {
          props.hotkey-overlay-title = "Restart Panel";
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
          ];
        };
        "Mod+Space" = _: {
          props.cooldown-ms = 200;
          props.hotkey-overlay-title = "Launcher";
          content.spawn-sh = "pkill -x fuzzel || ${
            lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
          }";
        };
        "Mod+V" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            (lib.getExe pkgs.kitty)
            "--class"
            "clipse"
            "-e"
            (lib.getExe pkgs.clipse)
          ];
        };
        "Mod+Ctrl+Space" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Command Runner";
          content.spawn-sh = ''
            pkill -x fuzzel ||
            sh -c "$(${
              lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
            } --lines 0 -d -p 'Run: ')"
          '';
        };
        "Mod+Period" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Emoji Picker";
          content.spawn = [
            (lib.getExe pkgs.bemoji)
          ];
        };
        "Mod+F1" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Lock Screen";
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock)
          ];
        };
        # "Mod+Escape" = _: {
        #   props.repeat = false;
        #   props.hotkey-overlay-title = "Power Menu";
        #   content.spawn = [
        #     (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
        #     "ipc"
        #     "call"
        #     "powermenu"
        #     "toggle"
        #   ];
        # };
        "Mod+A" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Quick Settings";
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "popover"
            "toggle"
            "quick_settings"
          ];
        };
        "Mod+N" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Notifications";
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "popover"
            "toggle"
            "notifications"
          ];
        };

        XF86MonBrightnessUp = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "brightness"
            "inc"
            "2"
          ];
        };
        "Mod+XF86AudioRaiseVolume" = _: {
          props.allow-when-locked = true;
          props.hotkey-overlay-title = "Increase Brightness";
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "brightness"
            "inc"
            "2"
          ];
        };
        "Mod+XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          props.hotkey-overlay-title = "Decrease Brightness";
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "brightness"
            "dec"
            "2"
          ];
        };
        XF86MonBrightnessDown = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "brightness"
            "dec"
            "2"
          ];
        };
        XF86AudioPlay = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "media"
            "play-pause"
          ];
        };
        XF86AudioStop = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "media"
            "stop"
          ];
        };
        XF86AudioPrev = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "media"
            "previous"
          ];
        };
        XF86AudioNext = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.vibepanel)
            "media"
            "next"
          ];
        };
      };
      settings.window-rules = [
        {
          matches = [ { app-id = "clipse"; } ];
          default-floating-position = _: {
            props = {
              x = 0;
              y = 70;
              relative-to = "top";
            };
          };
          default-window-height = [
            { proportion = 0.7; }
          ];
          default-column-width = [
            { proportion = 0.3; }
          ];
          open-floating = true;
        }
        {
          matches = [ { title = "Media Player"; } ];
          focus-ring = {
            off = { };
          };
        }
      ];
      settings.layer-rules = [
        {
          matches = [
            { layer = "overlay"; }
            # { namespace = "launcher"; }
          ];
          background-effect = {
            blur = true;
            xray = true;
          };
          geometry-corner-radius = 12;
        }
      ];
    };
}
