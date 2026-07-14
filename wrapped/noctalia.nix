{ self, inputs, ... }:
{
  flake.wrappersModules.noctalia = inputs.wrapper-modules.lib.wrapModule (
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
        package = lib.mkDefault inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        meta.maintainers = [ "Arc" ];
      };
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.noctalia = self.wrappersModules.noctalia.wrap {
        inherit pkgs;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        runtimePkgs = with pkgs; [ mpvpaper ];
        settings = {
          audio = {
            enable_overdrive = true;
          };
          backdrop = {
            enabled = true;
            tint_intensity = 0.6;
          };
          bar = {
            default = {
              background_opacity = 0.8;
              capsule = true;
              capsule_fill = "on_secondary";
              capsule_thickness = 0.8;
              capsule_group = [
                {
                  fill = "on_secondary";
                  id = "control";
                  members = [
                    "notifications"
                    "clipboard"
                    "mpvpaper"
                    "volume"
                    "brightness"
                    "battery"
                  ];
                  opacity = 0.4;
                  padding = 8.0;
                }
              ];
              capsule_opacity = 0.4;
              center = [
                "taskbar"
              ];
              dead_zone = {
                scroll_up_command = "niri msg action focus-workspace-up";
                scroll_down_command = "niri msg action focus-workspace-down";
              };
              end = [
                "tray"
                "group:control"
                "control-center"
              ];
              margin_edge = 0;
              margin_ends = 0;
              padding = 8;
              radius_bottom_left = 0;
              radius_bottom_right = 0;
              radius_top_left = 0;
              radius_top_right = 0;
              shadow = false;
              start = [
                "launcher"
                "media"
                "clock"
              ];
              thickness = 32;
              widget_spacing = 4;
            };
          };
          brightness = {
            enable_ddcutil = true;
          };
          control_center = {
            calendar.show_events_card = false;
            sidebar_section = "none";
            shortcuts = [
              { type = "wifi"; }
              { type = "bluetooth"; }
              { type = "caffeine"; }
              { type = "power_profile"; }
              { type = "dark_mode"; }
              { type = "notification"; }
            ];
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
          location = {
            auto_locate = true;
          };
          lockscreen = {
            blur_intensity = 0.0;
          };
          notification = {
            layer = "overlay";
          };
          osd = {
            position = "bottom_center";
            kinds = {
              media = false;
            };
          };
          plugins = {
            enabled = [ "noctalia/mpvpaper" ];
          };
          plugin_settings."noctalia/mpvpaper" = {
            video_directory = "/media/Storage/Wallpapers/Live/tsukihime";
          };
          shell = {
            animation = {
              speed = 4.0;
            };
            session = {
              grid = true;
              grid_columns = 4;
              actions = [
                {
                  action = "lock";
                  countdown_seconds = 0.0;
                  enabled = true;
                  shortcut = "1";
                  variant = "default";
                }
                {
                  action = "logout";
                  countdown_seconds = 3.0;
                  enabled = true;
                  shortcut = "2";
                  variant = "default";
                }
                {
                  action = "lock_and_suspend";
                  countdown_seconds = 3.0;
                  enabled = true;
                  label = "Suspend";
                  shortcut = "3";
                  variant = "default";
                }
                {
                  action = "reboot";
                  countdown_seconds = 3.0;
                  enabled = true;
                  shortcut = "4";
                  variant = "default";
                }
                {
                  action = "command";
                  command = "systemctl reboot --firmware-setup";
                  countdown_seconds = 3.0;
                  enabled = true;
                  label = "UEFI";
                  shortcut = "5";
                  variant = "outline";
                }
                {
                  action = "command";
                  command = "systemctl reboot --boot-loader-entry=auto-windows";
                  countdown_seconds = 3.0;
                  enabled = true;
                  glyph = "brand-windows-filled";
                  label = "Windows";
                  shortcut = "6";
                  variant = "primary";
                }
                {
                  action = "shutdown";
                  countdown_seconds = 3.0;
                  enabled = true;
                  shortcut = "7";
                  variant = "destructive";
                }
              ];
            };
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
            panel = {
              clipboard_placement = "floating";
              clipboard_position = "auto";
              control_center_placement = "floating";
              open_near_click_clipboard = true;
              open_near_click_control_center = true;
              open_near_click_launcher = true;
              transparency_mode = "soft";
              session_placement = "floating";
              session_position = "center";
              shadow = false;
              wallpaper_placement = "floating";
            };
            screen_corners = {
              enabled = true;
              size = 8;
            };
            screen_time_enabled = true;
            launcher = {
              app_grid = true;
              session_search = true;
            };
          };
          theme = {
            mode = "dark";
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
            refresh_minutes = 40;
          };
          widget = {
            clock = {
              format = " {:%A, %B %e } • {:%I:%M %P} ";
            };
            volume.scroll_step = 1;
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
            mpvpaper = {
              type = "noctalia/mpvpaper:mpvpaper";
            };
            taskbar = {
              anchor = true;
              capsule = false;
              capsule_fill = "on_primary";
              capsule_foreground = "primary";
              capsule_padding = 4.0;
              inactive_opacity = 0.5;
              group_by_workspace = true;
              hide_empty_workspaces = false;
              only_active_workspace = false;
              show_all_outputs = false;
              occupied_color = "tertiary";
              show_workspace_label = false;
              show_active_indicator = false;
              workspace_label_placement = "corner";
              scale = 1.4;
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
