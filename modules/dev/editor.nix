{ self, inputs, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
      imports = [
        self.homeModules.editor
        inputs.helix-plugins.homeManagerModules.default
      ];
    };
  };
  flake.homeModules.editor =
    { pkgs, lib, ... }:
    {
      nixpkgs.overlays = [ inputs.helix-plugins.overlays.default ];
      nixpkgs.config.allowUnfree = true;
      # IDE
      # home.packages = with pkgs; [
      # vscode-fhs
      # jetbrains.clion
      # jetbrains.datagrip
      # jetbrains.idea
      # ];
      xdg.configFile."helix/init.scm".text = ''
        (require "forest/forest.scm")
        (require "smooth-scroll/smooth-scroll.scm")
        (require "steel-pty/term.scm")

        ;; Optional: which side the tree renders on ('left by default), and which
        ;; entry names are always hidden
        (forest-configure! 'left #:ignore (list ".git" "target" "__pycache__"))

        ;; Optional: which explorer UI forest-open uses ('snacks by default)
        ;; (forest-set-style! style)
        (forest-set-style! 'snacks) ; or 'mini

        ;; Optional (snacks): wrapping j/k inside a folder, and h/l to enter or leave
        (forest-snack-circular-keybinds #t)

        ;; Optional (snacks): give the sidebar its own background per focus state, so the
        ;; tree stands apart from the buffer.
        (forest-set-sidebar-bg! #:focused "#1e1e2e" #:unfocused "#181825")

        ;; Optional (snacks): color the search box outline. It marks focus by default
        ;; (orange focused, white unfocused); override the colors, or stop it changing.
        (forest-set-search-color! #:focused "#89b4fa" #:unfocused "#585b70")
        (forest-set-search-color! #:always "#89b4fa")            ; one color, both states
        (forest-set-search-color! #:focused "#89b4fa" #:follow-focus? #f) ; never changes
      '';
      xdg.configFile."helix/helix.scm".text = '''';          
      programs.helix = {
        enable = true;
        defaultEditor = true;
        plugins = with pkgs.helixPlugins; [
          forest
          smooth-scroll
          steel-pty
        ];
        package = pkgs.steelix;
        settings = {
          editor = {
            bufferline = "always";
            color-modes = true;
            line-number = "relative";
            shell = [
              "nu"
              "--commands"
            ];
            cursorline = true;
            file-picker.hidden = false;
            lsp.display-messages = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            rainbow-brackets = true;
            soft-wrap = {
              enable = true;
              max-indent-retain = 45;
            };
            statusline.mode = {
              insert = "INSERT";
              normal = "NORMAL";
              select = "SELECT";
            };
            indent-guides = {
              character = "▏";
              render = true;
            };
            whitespace = {
              characters.tab = "→";
              render.tab = "all";
            };
          };
          keys = {
            normal = {
              C-j = [
                "extend_to_line_bounds"
                "delete_selection"
                "paste_after"
              ];
              C-k = [
                "extend_to_line_bounds"
                "delete_selection"
                "move_line_up"
                "paste_before"
              ];
              C-t = [ ":open-term" ];
              C-b = [ ":forest-open" ];
              C-d = [ ":half-page-down-smooth" ];
              C-u = [ ":half-page-up-smooth" ];
              pageup = [ ":page-up-smooth" ];
              pagedown = [ ":page-down-smooth" ];
              A-s = [ ":write " ];
              A-w = [ ":bc" ];
            };
          };
          theme = "catppuccin_mocha";
        };
        languages.language = 
          (
            {
              astro = "astro";
              css = "css";
              html = "html";
              javascript = "js";
              json = "json";
              jsonc = "jsonc";
              jsx = "jsx";
              markdown = "md";
              scss = "scss";
              svelte = "svelte";
              tsx = "tsx";
              typescript = "ts";
              vue = "vue";
              yaml = "yaml";
            }
            |> builtins.mapAttrs (
              name: extension:
              {
                inherit name;

                auto-format = true;
                formatter.command = (lib.getExe pkgs.deno);
                formatter.args = [
                  "fmt"
                  "--unstable-component"
                  "--ext"
                  extension
                  "-"
                ];
              }
              //
                lib.attrsets.optionalAttrs
                  (lib.lists.elem name [
                    "javascript"
                    "jsx"
                    "typescript"
                    "tsx"
                  ])
                  {
                    language-servers = [ "deno" ];
                  }
            )
            |> lib.attrsets.attrValues
          )
          ++ [
            {
              name = "nix";
              auto-format = true;
              formatter.command = "nixfmt";
            }

            {
              name = "python";
              auto-format = true;
              language-servers = [ "basedpyright" ];
            }

            {
              name = "toml";
              auto-format = true;
            }

            {
              name = "rust";
              auto-format = true;
            }
          ];
      };
    };
}
