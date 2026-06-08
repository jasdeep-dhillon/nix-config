{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
      imports = [ self.homeModules.zed ];
    };
  };
  flake.homeModules.zed =
    { pkgs, lib, ... }:
    {
      programs.zed-editor = {
        enable = true;
        extensions = [
          "html"
          "toml"
          "catppuccin"
          "java"
          "git-firefly"
          "dockerfile"
          "php"
          "astro"
          "log"
          "nix"
          "biome"
          "colored-zed-icons-theme"
          "cargo-tom"
          "fish"
          "nu"
          "qml"
          "hyprland"
          "kdl"
          "github-actions"
          "html-snippets"
          "gitignore-templates"
          "just"
        ];
        userSettings = {
          inlay_hints = {
            enabled = true;
            show_value_hints = true;
            show_type_hints = true;
            show_parameter_hints = true;
            show_other_hints = true;
            show_background = false;
          };
          project_panel = {
            diagnostic_badges = true;
          };
          features = {
            copilot = true;
          };
          telemetry = {
            metrics = false;
            diagnostics = false;
          };
          indent_guides = {
            enabled = true;
            coloring = "indent_aware";
          };
          diagnostics = {
            include_warnings = true;
            inline = {
              enabled = true;
              padding = 4;
            };
          };
          theme = lib.mkForce {
            mode = "system";
            light = "Catppuccin Latte";
            dark = "Catppuccin Mocha";
          };
          ui_font_family = lib.mkForce "Maple Mono NL NF";
          ui_font_size = lib.mkForce 16;
          buffer_font_size = lib.mkForce 14;
          buffer_font_family = "Maple Mono NL NF";
          cursor_blink = false;
          autosave = {
            after_delay.milliseconds = 400;
          };
          formatter = "auto";
          soft_wrap = "editor_width";
          terminal = {
            font_family = "Maple Mono NL NF";
            font_size = 13;
            copy_on_select = true;
            line_height.custom = 1.35;
            toolbar.breadcrumbs = false;
            cursor_shape = "bar";
          };
          minimap.show = "always";
          lsp = {
            rust-analyzer = {
              binary = {
                path = lib.getExe pkgs.rust-analyzer;
              };
            };
          };
        };
        userKeymaps = [
          {
            context = "Workspace";
            bindings = {
              ctrl-alt-up = "editor::AddSelectionAbove";
              ctrl-alt-down = "editor::AddSelectionBelow";
              "shift shift" = "file_finder::Toggle";
            };
          }
          {
            context = "Terminal";
            bindings = {
              ctrl-b = "workspace::ToggleLeftDock";
            };
          }
        ];
      };
    };
}
