{ self, inputs, ... }:
{
  flake.nixosModules.programs =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.default ];
      home-manager.users.arc = {
        imports = [ self.homeModules.programs ];
      };
      security.polkit.enable = true;
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
      programs.bat = {
        enable = true;
        settings = {
          theme = ''"Catppuccin Mocha"'';
        };
      };
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
      };
      environment.shells = [ pkgs.nushell ];
    };

  flake.nixosModules.guiPrograms =
    { pkgs, config, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.default ];
      home-manager.users.arc = {
        imports = [ self.homeModules.guiPrograms ];
      };
      programs.obs-studio = {
        enable = true;
        # optional Nvidia hardware acceleration
        package = (
          pkgs.obs-studio.override {
            cudaSupport = config.hardware.nvidia.enabled;
          }
        );
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi # optional AMD hardware acceleration
          obs-gstreamer
          obs-vkcapture
        ];
      };
    };

  flake.homeModules.guiPrograms =
    { pkgs, ... }:
    {
      programs.kitty = {
        enable = true;
        settings = {
          detect_urls = "yes";
          copy_on_select = "yes";
          cursor_shape = "beam";
          cursor_shape_unfocused = "unchanged";
          confirm_os_window_close = 0;
          open_url_with = "default";
          underline_hyperlinks = "always";
          strip_trailing_spaces = "smart";
          window_margin_width = 4;
          mouse_map = "middle release ungrabbed paste_from_selection";
        };
        extraConfig = ''
          background_opacity 0.9
        '';
      };
      programs.mangohud = {
        enable = true;
        settings = {
          gpu_stats = true;
          gpu_temp = true;
          # gpu_core_clock
          # gpu_mem_temp
          # gpu_mem_clock
          # gpu_power
          # gpu_power_limit
          # cpu_temp
          # cpu_power
          # cpu_mhz
          # vram
          # ram
          # fps
          # frametime
          # throttling_status
          # gpu_name
          # vulkan_driver
          # wine
          # winesync
          # frame_timing
          # gamemode
          # text_outline
          # hud_no_margin
          # hud_compact
          # font_size = 20
          # width = 325
          # table-columns = 5
          # background_alpha = 0.2
          # pci_dev = \0000:01:00.0\
          # toggle_hud = \Shift_L+F12\
          # toggle_hud = \Shift_R+F12\
        };
      };
      programs.mpv = {
        enable = true;
        config = {
          geometry = "50%:50%";
          autofit-larger = "100%x99%";
          force-window = "immediate";
          profile = "high-quality";
          hwdec = "auto";
          slang = "en";
          border = "no";
          ao = "pulse";
          save-position-on-quit = true;
          keep-open = true;
          keepaspect-window = "no";
          screenshot-directory = "~/Pictures/MPV-Screenshots";
          screenshot-template = "%F %p";
        };
        bindings = {
          "[" = "add speed -0.25";
          "]" = "add speed 0.25";
          "4" = " ignore";
          "5" = " ignore";
          "6" = " ignore";
          "7" = " ignore";
          "8" = " ignore";
          "9" = " ignore";
          "0" = " ignore";
          "1" = " cycle sub down"; # switch subtitle track
          "2" = " cycle sub"; # switch subtitle track backwards
          "3" = " cycle audio";
          "ESC" = " set fullscreen no";
          "w" = " ignore";
          "e" = " ignore";
          "p" = " ignore";
          "j" = " ignore";
          "J" = " ignore";
          "WHEEL_UP" = "      add volume 5";
          "WHEEL_DOWN" = "    add volume -5";
          "=      add" = " volume 5";
          "-   add" = " volume -5";
          "i" = " script-binding stats/display-stats-toggle";
          "RIGHT" = " seek  10"; # seek 5 seconds forward
          "LEFT" = "  seek -10";
          "v" = "   playlist-prev"; # skip to the previous file
          "b" = " playlist-next"; # skip to the next file
          "alt+c" = " script-message-to crop toggle-crop hard";
          "alt+e" = "script-message-to encode set-timestamp";
        };
        extraInput = "";
        scripts = with pkgs.mpvScripts; [
          pkgs.mpvScripts.builtins.autoload
          sponsorblock-minimal
          youtube-chat
          twitch-chat
          mpris
          eisa01.smartskip
          webtorrent-mpv-hook
          occivink.crop
          occivink.encode
        ];
      };
    };

  flake.homeModules.programs =
    { lib, config, ... }:
    {
      xdg.configFile."fastfetch/nekoarc.png".source = ../icons/nekoarc.png;
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            type = "auto";
            source = "~/.config/fastfetch/nekoarc.png";
            width = 35;
            height = 20;
          };
          display = {
            separator = "->";
            color = {
              keys = "blue";
            };
            # key = {
            #   width = 6;
            #   type = "icon";
            # };
          };
          modules = [
            "title"
            "seperator"
            {
              type = "os";
              format = "{name} {version}";
            }
            {
              type = "host";
              format = "{family}";
            }
            "kernel"
            "packages"
            "shell"
            "de"
            "wm"
            "terminal"
            "separator"
            {
              type = "cpu";
              format = "{name} ({cores-physical} Cores/{cores-logical} Threads)";
            }
            "gpu"
            "memory"
            "swap"
            "disk"
            "separator"
            "localip"
            "battery"
            "poweradapter"
          ];
        };
      };
      programs.starship = {
        enable = true;
        settings = {
          palette = lib.mkForce "catppuccin_mocha";
          format = lib.concatStrings [
            "$hostname"
            "$directory"
            "$git_branch"
            "$git_state"
            "$git_status"
            "$fill"
            "$bun"
            "$c"
            "$elixir"
            "$elm"
            "$golang"
            "$gradle"
            "$haskell"
            "$java"
            "$julia"
            "$nodejs"
            "$nim"
            "$rust"
            "$scala"
            "$python"
            "$nix_shell"
            "$time"
            "$cmd_duration"
            "\n$character"
          ];
          right_format = "";
          add_newline = false;
          hostname = {
            format = "[](fg:#f5c2e7)[ $hostname ]($style)[](fg:#f5c2e7) ";
            style = "fg:#1C3A5E bg:#f5c2e7";
          };
          directory = {
            format = "[](fg:#7287fd)[  $path ]($style)[](fg:#7287fd)";
            style = "fg:#dce0e8 bg:#7287fd";
            truncation_length = 3;
          };
          fill = {
            symbol = " ";
          };
          git_branch = {
            format = " [](fg:#FCF392)[$symbol$branch(:$remote_branch) ]($style)";
            symbol = "  ";
            style = "fg:#1C3A5E bg:#FCF392";
          };
          git_status = {
            format = "[$all_status]($style)[](fg:#FCF392)";
            style = "fg:#1C3A5E bg:#FCF392";
          };
          git_metrics = {
            format = "[+$added/-$deleted](fg:#1C3A5E bg:#FCF392)[](fg:#FCF392)";
            added_style = "fg:#1C3A5E bg:#FCF392";
            deleted_style = "fg:bright-red bg:#FCF392";
            disabled = false;
          };
          hg_branch = {
            format = "[ $symbol$branch ]($style)";
            symbol = " ";
          };
          cmd_duration = {
            min_time = 500;
            format = " [](fg:lavender)[ $duration]($style)[](fg:lavender)";
            style = "fg:#181825 bg:lavender";
          };
          character = {
            success_symbol = "[ ❯](bold green) ";
            error_symbol = "[ ](red) ";
          };
          time = {
            disabled = false;
            time_format = "%I:%M %P";
            style = "bg:#1d2230";
            format = " [](fg:#1C3A5E)[[󱑍 $time](bg:#1C3A5E fg:#8DFBD2)]($style)[](fg:#1C3A5E)";
          };
          bun = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[$symbol($version)]($style)[](fg:mauve)";
          };
          c = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[$symbol ($version)]($style)[](fg:mauve)";
          };
          docker_context = {
            symbol = " ";
            style = "bg:peach fg:mantle";
            format = " [](fg:peach)[$symbol $context]($style)[](fg:peach)";
          };
          elixir = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          elm = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          golang = {

            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          gradle = {
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };
          haskell = {
            symbol = " ";
            style = "bg:#mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          java = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          julia = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          nix_shell = {
            symbol = "󱄅 ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          nodejs = {
            symbol = "";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[$symbol ($version)]($style)[](fg:mauve)";
          };

          nim = {
            symbol = "󰆥 ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          python = {
            symbol = "";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) \${virtualenv} ]($style)[](fg:mauve)";
          };

          rust = {
            symbol = "";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };

          scala = {
            symbol = " ";
            style = "bg:mauve fg:mantle";
            format = " [](fg:mauve)[ $symbol ($version) ]($style)[](fg:mauve)";
          };
          palettes.catppuccin_mocha = {
            rosewater = "#f5e0dc";
            flamingo = "#f2cdcd";
            pink = "#f5c2e7";
            mauve = "#cba6f7";
            red = "#f38ba8";
            maroon = "#eba0ac";
            peach = "#fab387";
            yellow = "#f9e2af";
            green = "#a6e3a1";
            teal = "#94e2d5";
            sky = "#89dceb";
            sapphire = "#74c7ec";
            blue = "#89b4fa";
            lavender = "#b4befe";
            text = "#cdd6f4";
            subtext1 = "#bac2de";
            subtext0 = "#a6adc8";
            overlay2 = "#9399b2";
            overlay1 = "#7f849c";
            overlay0 = "#6c7086";
            surface2 = "#585b70";
            surface1 = "#45475a";
            surface0 = "#313244";
            base = "#1e1e2e";
            mantle = "#181825";
            crust = "#11111b";
          };
        };
      };
      programs.nushell = {
        enable = true;
        settings = {
          buffer_editor = "zeditor";
          show_banner = false;
        };
        environmentVariables = {
          TRANSIENT_PROMPT_COMMAND = "";
          CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
        };
        shellAliases = {
          cls = "clear";
          zed = "zeditor";
          nixos = "cd /media/Storage/Projects/nix-config/";
          projects = "cd /media/Storage/Projects";
        };

        # Carapace & Starship module
        extraConfig = ''
          $env.PATH = ($env.PATH | split row (char esep) | where { $in != "${config.home.homeDirectory}/.config/carapace/bin" } | prepend "${config.home.homeDirectory}/.config/carapace/bin")

          def --env get-env [name] { $env | get $name }
          def --env set-env [name, value] { load-env { $name: $value } }
          def --env unset-env [name] { hide-env $name }

          let carapace_completer = {|spans|
            load-env {
            	CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
            	CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
            }

            # if the current command is an alias, get it's expansion
            let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

            # overwrite
            let spans = (if $expanded_alias != null  {
              # put the first word of the expanded alias first in the span
              $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
            } else {
              $spans | skip 1 | prepend ($spans.0)
            })

            carapace $spans.0 nushell ...$spans
            | from json
          }

          mut current = (($env | default {} config).config | default {} completions)
          $current.completions = ($current.completions | default {} external)
          $current.completions.external = ($current.completions.external
          | default true enable
          # backwards compatible workaround for default, see nushell #15654
          | upsert completer { if $in == null { $carapace_completer } else { $in } })

          $env.config = $current

          export-env { $env.STARSHIP_SHELL = "nu"; load-env {
              STARSHIP_SESSION_KEY: (random chars -l 16)
              PROMPT_MULTILINE_INDICATOR: (
                  ^starship prompt --continuation
              )

              # Does not play well with default character module.
              # TODO: Also Use starship vi mode indicators?
              PROMPT_INDICATOR: ""

              PROMPT_COMMAND: {||
                  (
                      # The initial value of `$env.CMD_DURATION_MS` is always `0823`, which is an official setting.
                      # See https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687.
                      let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
                      ^starship prompt
                          --cmd-duration $cmd_duration
                          $"--status=($env.LAST_EXIT_CODE)"
                          --terminal-width (term size).columns
                          ...(
                              if (which "job list" | where type == built-in | is-not-empty) {
                                  ["--jobs", (job list | length)]
                              } else {
                                  []
                              }
                          )
                  )
              }

              config: ($env.config? | default {} | merge {
                  render_right_prompt_on_last_line: true
              })

              PROMPT_COMMAND_RIGHT: {||
                  (
                      # The initial value of `$env.CMD_DURATION_MS` is always `0823`, which is an official setting.
                      # See https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687.
                      let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
                      ^starship prompt
                          --right
                          --cmd-duration $cmd_duration
                          $"--status=($env.LAST_EXIT_CODE)"
                          --terminal-width (term size).columns
                          ...(
                              if (which "job list" | where type == built-in | is-not-empty) {
                                  ["--jobs", (job list | length)]
                              } else {
                                  []
                              }
                          )
                  )
              }
          }}
        '';
      };
      programs.carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
}
