{ self, inputs, ... }:
{
  flake.wrappersModules.vibepanel = inputs.wrapper-modules.lib.wrapModule (
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    let
      tomlFmt = pkgs.formats.toml { };
    in
    {
      imports = [ wlib.modules.default ];
      options = {
        settings = lib.mkOption {
          type = tomlFmt.type;
          default = { };
          description = ''
            Configuration of Vibepanel
            See <https://github.com/prankstr/vibepanel/wiki/Configuration>
          '';
        };
      };
      config = {
        flags."--config" = config.constructFiles.generatedConfig.path;
        constructFiles.generatedConfig = {
          content = builtins.readFile (
            toString (tomlFmt.generate config.constructFiles.generatedConfig.relPath config.settings)
          );
          relPath = "${config.binName}.toml";
        };
        package = lib.mkDefault inputs.vibepanel.packages.${pkgs.stdenv.hostPlatform.system}.default;
        meta.maintainers = [ "Arc" ];
      };
    }
  );
  perSystem =
    {
      pkgs,
      self',
      lib,
      ...
    }:
    {
      packages.vibepanel = self.wrappersModules.vibepanel.wrap {
        inherit pkgs;
        package = inputs.vibepanel.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = {
          bar = {
            position = "top";
            size = 30;
            spacing = 2;
            inset = 4;
            screen_margin = 4;
            border_radius = 60;
            popover_offset = 4;
            background_opacity = 0.75;
            background_color = "#1e1e2e";
            outline = false;
          };
          widgets = {
            left = [
              "custom-fuzzel"
              "media"
              "clock"
            ];
            center = [ "taskbar" ];
            right = [
              "tray"
              "custom-clipboard"
              "notifications"
              "cpu"
              "battery"
              "quick_settings"
            ];
            outline = false;
            border_radius = 60;
            background_opacity = 0.7;
            background_color = "#1e1e2e";
            popover_background_opacity = 0.9;
            clock = {
              format = "%I:%M %p • %A, %b %-d";
            };
            media = {
              visualizer = true;
            };
            custom-fuzzel = {
              icon = "apps";
              # label = "Launcher";
              tooltip = "Fuzzel";
              on_click = "pkill -x fuzzel || ${lib.getExe self'.packages.fuzzel}";
              on_click_right = ''
                pkill -x fuzzel ||
                sh -c "$(fuzzel --lines 0 -d -p 'Run: ')"
              '';
            };
            custom-clipboard = {
              icon = "content_paste";
              tooltip = "Clipboard";
              on_click = "kitty --class clipse -e ${lib.getExe pkgs.clipse}";
            };
          };
          theme = {
            mode = "auto";
            scheme = "dark";
            accent = "#b4befe";
            animations = true;
            ripple = false;
            blur = true;
            outline = true;
            outline_width = 2;
            outline_opacity = 0.8;
            icons = {
              theme = "material";
              weight = 400;
            };
            states = {
              success = "#a6e3a1";
              warning = "#f9e2af";
              urgent = "#f38ba8";
            };
            typography.font_family = "Inter";
          };
          osd = {
            enabled = true;
            position = "bottom";
            show_value = true;
          };
          advanced.compositor = "niri";
        };
      };
    };
}
