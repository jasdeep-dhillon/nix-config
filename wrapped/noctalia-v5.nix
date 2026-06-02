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
        generatedConfigDirname = lib.mkOption {
          type = lib.types.str;
          default = "${config.binName}";
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
        settings = lib.mkOption {
          type = wlib.types.structuredValueWith { typeName = "TOML"; };
          default = { };
          description = ''
            Noctalia shell configuration settings as an attribute set,
            to be written to $NOCTALIA_CONFIG_HOME/noctalia/settings.json`.
          '';
        };
        colors = lib.mkOption {
          type = wlib.types.structuredValueWith { typeName = "TOML"; };
          default = { };
          description = ''
            Noctalia shell color configuration as an attribute set
          '';
        };
      };

      config = {
        env = {
          NOCTALIA_CONFIG_HOME = "${placeholder config.configDrvOutput}";
        };
        constructFiles.settings = {
          content = builtins.readFile (
            tomlFmt.generate config.constructFiles.settings.relPath config.settings
          );
          output = lib.mkOverride 0 config.configDrvOutput;
          relPath = lib.mkOverride 0 "noctalia/settings.toml";
        };
        constructFiles.colors = {
          content = builtins.toJSON config.colors;
          output = lib.mkOverride 0 config.configDrvOutput;
          relPath = lib.mkOverride 0 "noctalia/palettes/custom.json";
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
          backdrop = {
            tint_intensity = 0.6;
          };
          bar = {
            default = {
              attach_panels = true;
              background_opacity = 0.8;
              capsule = true;
              capsule_fill = "on_secondary";
              capsule_group = [
                {
                  fill = "on_secondary";
                  id = "control";
                  members = [
                    "volume"
                    "brightness"
                    "battery"
                  ];
                  opacity = 0.4;
                  padding = 6.0;
                }
              ];
              capsule_opacity = 0.4;
              center = [
                "taskbar"
              ];
              end = [
                "tray"
                "notifications"
                "clipboard"
                "group:control"
                "control-center"
              ];
              margin_edge = 4;
              margin_ends = 4;
              padding = 4;
              shadow = false;
              start = [
                "launcher"
                "media"
                "clock"
              ];
              widget_spacing = 4;
            };
          };
          # brightness = {
          #   enable_ddcutil = true;
          # };
          control_center.sidebar_section = "none";

          control_center.shortcuts = [
            { type = "wifi"; }
            { type = "bluetooth"; }
            { type = "caffeine"; }
            { type = "power_profile"; }
            { type = "dark_mode"; }
            { type = "notification"; }
          ];
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
            time_format = "{:%I:%M %P}";
            launch_apps_as_systemd_services = true;
            corner_radius_scale = 1.45;
            font_family = "Inter";
            # niri_overview_type_to_launch_enabled = true;
            password_style = "random";
            polkit_agent = true;
            settings_show_advanced = true;
            telemetry_enabled = true;
            animation = {
              speed = 4.0;
            };
            panel = {
              attach_clipboard = true;
              clipboard_placement = "attached";
              attach_launcher = false;
              open_near_click_clipboard = true;
              open_near_click_control_center = true;
              open_near_click_launcher = true;
              transparency_mode = "soft";
              session_placement = "centered";
              shadow = false;
            };
            screen_corners = {
              enabled = true;
              size = 8;
            };
            screen_time_enabled = true;
          };
          theme = {
            mode = "auto";
            # builtin = "Catppuccin";
            # community_palette = "Catppuccin Lavender";
            # source = "community";
            source = "custom";
            custom_palette = "custom";
          };
          wallpaper = {
            directory = "/home/arc/Pictures/Wallpapers";
            default = {
              path = self.wallpaper;
            };
            last = {
              path = self.wallpaper;
            };
            monitors."DP-1" = {
              path = self.wallpaper;
            };
            monitors."eDP-1" = {
              path = self.wallpaper;
            };
          };
          weather = {
            auto_locate = true;
            refresh_minutes = 60;
          };
          widget = {
            clock = {
              format = " {:%A, %B %e } • {:%I:%M %P} ";
            };
            volume.scroll_step = 2;
            volume.show_label = false;
            brightness.show_label = false;
            battery = {
              show_label = false;
              display_mode = "graphic";
              scale = 0.6;
            };
            control-center = {
              glyph = "layout-board-filled";
            };
            launcher = {
              glyph = "grid-dots";
            };
            media = {
              max_length = 200.0;
            };
            taskbar = {
              anchor = true;
              capsule = false;
              capsule_fill = "on_primary";
              capsule_foreground = "primary";
              capsule_padding = 4.0;
              group_by_workspace = true;
              hide_empty_workspaces = false;
              only_active_workspace = false;
              show_all_outputs = false;
              occupied_color = "tertiary";
              show_workspace_label = false;
              workspace_label_placement = "inside";
              scale = 1.25;
            };
            tray = {
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
        colors = {
          dark = {
            mPrimary = "#b4befe";
            mOnPrimary = "#11111b";
            mSecondary = "#f5bde6";
            mOnSecondary = "#11111b";
            mTertiary = "#a6adc8";
            mOnTertiary = "#11111b";
            mError = "#f38ba8";
            mOnError = "#11111b";
            mSurface = "#181825";
            mOnSurface = "#cdd6f4";
            mSurfaceVariant = "#1e1e2e";
            mOnSurfaceVariant = "#a3b4eb";
            mOutline = "#4c4f69";
            mShadow = "#11111b";
            mHover = "#a6adc8";
            mOnHover = "#11111b";
            terminal = {
              foreground = "#cdd6f4";
              background = "#1e1e2e";
              selectionFg = "#cdd6f4";
              selectionBg = "#585b70";
              cursorText = "#1e1e2e";
              cursor = "#f5e0dc";
              normal = {
                black = "#45475a";
                red = "#f38ba8";
                green = "#a6e3a1";
                yellow = "#f9e2af";
                blue = "#89b4fa";
                magenta = "#f5c2e7";
                cyan = "#94e2d5";
                white = "#a6adc8";
              };
              bright = {
                black = "#585b70";
                red = "#f37799";
                green = "#89d88b";
                yellow = "#ebd391";
                blue = "#74a8fc";
                magenta = "#f2aede";
                cyan = "#6bd7ca";
                white = "#bac2de";
              };
            };
          };
          light = {
            mPrimary = "#1e66f5";
            mOnPrimary = "#eff1f5";
            mSecondary = "#ea76cb";
            mOnSecondary = "#eff1f5";
            mTertiary = "#8839ef";
            mOnTertiary = "#eff1f5";
            mError = "#d20f39";
            mOnError = "#dce0e8";
            mSurface = "#eff1f5";
            mOnSurface = "#4c4f69";
            mSurfaceVariant = "#ccd0da";
            mOnSurfaceVariant = "#6c6f85";
            mOutline = "#a5adcb";
            mShadow = "#dce0e8";
            mHover = "#d20f39";
            mOnHover = "#eff1f5";
            terminal = {
              foreground = "#c6d0f5";
              background = "#303446";
              selectionFg = "#c6d0f5";
              selectionBg = "#626880";
              cursorText = "#303446";
              cursor = "#f2d5cf";
              normal = {
                black = "#51576d";
                red = "#e78284";
                green = "#a6d189";
                yellow = "#e5c890";
                blue = "#8caaee";
                magenta = "#f4b8e4";
                cyan = "#81c8be";
                white = "#a5adce";
              };
              bright = {
                black = "#626880";
                red = "#e67172";
                green = "#8ec772";
                yellow = "#d9ba73";
                blue = "#7b9ef0";
                magenta = "#f2a4db";
                cyan = "#5abfb5";
                white = "#b5bfe2";
              };
            };
          };
        };
      };
    };
}
