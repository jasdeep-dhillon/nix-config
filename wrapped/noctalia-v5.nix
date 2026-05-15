{ self, inputs, ... }:
{
  flake.wrappersModules.noctalia-v5 = inputs.wrapper-modules.lib.wrapModule (
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
            Configuration of Noctalia V5
          '';
        };
        generatedConfigDirname = lib.mkOption {
          type = lib.types.str;
          default = "${config.binName}-config";
          description = "Name of the directory which is created as the NOCTALIA_CONFIG_HOME in the wrapper output";
          apply = x: lib.removePrefix "/" (lib.removeSuffix "/" x);
        };
        configDrvOutput = lib.mkOption {
          type = lib.types.str;
          default = config.outputName;
          description = "Name of the derivation output where the generated NOCTALIA_CONFIG_HOME is output to.";
        };
        configPlaceholder = lib.mkOption {
          type = lib.types.str;
          default = "${placeholder config.configDrvOutput}/${config.generatedConfigDirname}";
          readOnly = true;
          description = ''
            The placeholder for the generated config directory.

            Use this inside the module to place files in an ad-hoc manner within it.

            Outside of the module, you should instead use `wrapped-noctalia-shell.generatedConfig` to get the path.
          '';
        };
      };

      config = {
        env = {
          NOCTALIA_CONFIG_HOME = "${config.configDrvOutput}/";
        };
        # flags."--config" = config.constructFiles.generatedConfig.path;
        constructFiles.settings = {
          content = builtins.readFile (tomlFmt.generate config.constructFiles.settings.relPath config.settings);
          output = config.configDrvOutput;
          relPath = "${config.generatedConfigDirname}/settings.toml";
        };
        package = lib.mkDefault inputs.noctalia-v5.packages.${pkgs.stdenv.hostPlatform.system}.default;
        meta.maintainers = [ "Arc" ];
      };
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia-v5 = self.wrappersModules.noctalia-v5.wrap {
        inherit pkgs;
        package = inputs.noctalia-v5.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = {
          audio = {
            enable_overdrive = true;
          };
          bar = {
            default = {
              attach_panels = false;
              background_opacity = 0.8;
              capsule = true;
              capsule_fill = "on_secondary";
              capsule_opacity = 0.4;
              center = [
                "workspaces"
                "active_window"
              ];
              end = [
                "tray"
                "power_profiles"
                "notifications"
                "clipboard"
                "volume"
                "brightness"
                "battery"
                "control-center"
              ];
              margin_edge = 4;
              margin_ends = 4;
              padding = 4;
              shadow = false;
              start = [
                "launcher"
                "temp"
                "clock"
                "media"
              ];
              widget_spacing = 4;
            };
          };
          brightness = {
            enable_ddcutil = true;
          };
          desktop_widgets = {
            enabled = false;
          };
          idle = {
            behavior_order = [
              "lock"
              "screen-off"
              "suspend"
            ];
            behavior = {
              lock = {
                action = "lock";
                enabled = true;
                timeout = 600;
              };
              screen-off = {
                action = "screen_off";
                enabled = true;
                timeout = 660;
              };
              suspend = {
                action = "suspend";
                enabled = true;
                lock_before_suspend = true;
                timeout = 900;
              };
            };
          };
          notification = {
            layer = "overlay";
          };
          osd = {
            position = "bottom_center";
          };
          shell = {
            avatar_path = self.avatar;
            font_family = "Inter";
            telemetry_enabled = true;
            animation = {
              speed = 1.7;
            };
            panel = {
              attach_clipboard = true;
              attach_launcher = true;
              open_near_click_clipboard = true;
              open_near_click_control_center = true;
              open_near_click_launcher = true;
              transparency_mode = "glass";
            };
            screen_corners = {
              enabled = true;
              size = 8;
            };
          };
          theme = {
            builtin = "Catppuccin";
            community_palette = "Catppuccin Lavender";
            source = "community";
          };
          wallpaper = {
            directory = "/home/arc/Pictures/Wallpapers";
            default = {
              path = self.wallpaper;
            };
            last = {
              path = "/home/arc/Pictures/Wallpapers/Fk_wf9uagAIrb8M.jpg";
            };
          };
          weather = {
            auto_locate = true;
          };
          widget = {
            clock = {
              format = "{:%H:%M %P}";
            };
            control-center = {
              glyph = "layout-board-filled";
            };
            launcher = {
              glyph = "grid-dots";
            };
            tray = {
              capsule = false;
              drawer = false;
            };
            workspaces = {
              capsule = true;
              display = "none";
              empty_color = "on_primary";
              occupied_color = "primary";
            };
          };
        };
      };
    };
}
