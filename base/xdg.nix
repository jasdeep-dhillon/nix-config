{ self, ... }:
{
  flake.nixosModules.xdg =
    { config, ... }:
    {
      # X11's display-manager session script creates ~/.compose-cache unless
      # this is set to an absolute path. It has to be a PAM/session variable
      # because the script runs before the user's systemd session exists.
      environment.sessionVariables.XCOMPOSECACHE = "${
        config.users.users.${self.username}.home
      }/.cache/X11/xcompose";
    };

  flake.homeModules.xdg =
    { config, lib, ... }:
    let
      inherit (config.xdg)
        cacheHome
        configHome
        dataHome
        stateHome
        ;
      configHomeRelative = lib.removePrefix "${config.home.homeDirectory}/" configHome;

      sessionVariables = {
        # Rust
        CARGO_HOME = "${dataHome}/cargo";
        RUSTUP_HOME = "${dataHome}/rustup";

        # JavaScript / TypeScript
        NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
        NPM_CONFIG_CACHE = "${cacheHome}/npm";
        NODE_REPL_HISTORY = "${stateHome}/node_repl_history";
        BUN_INSTALL = "${dataHome}/bun";
        DENO_DIR = "${cacheHome}/deno";
        PNPM_HOME = "${dataHome}/pnpm";

        # Python
        PYTHON_HISTORY = "${stateHome}/python_history";
        IPYTHONDIR = "${configHome}/ipython";
        JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
        JUPYTER_DATA_DIR = "${dataHome}/jupyter";
        JUPYTER_RUNTIME_DIR = "${stateHome}/jupyter/runtime";

        # Go
        GOPATH = "${dataHome}/go";
        GOCACHE = "${cacheHome}/go-build";

        # JVM / Android
        GRADLE_USER_HOME = "${dataHome}/gradle";
        ANDROID_USER_HOME = "${dataHome}/android";
        ANDROID_AVD_HOME = "${dataHome}/android/avd";

        # Containers
        DOCKER_CONFIG = "${configHome}/docker";
        KUBECONFIG = "${configHome}/kube/config";

        # Secrets / Wine
        GNUPGHOME = "${dataHome}/gnupg";
        PASSWORD_STORE_DIR = "${dataHome}/password-store";
        WINEPREFIX = "${dataHome}/wine";

        # AI / agent CLIs
        CODEX_HOME = "${configHome}/codex";
        COPILOT_HOME = "${configHome}/copilot";
        GEMINI_CLI_HOME = "${configHome}/gemini";
        PI_CONFIG_DIR = "${configHomeRelative}/omp";

        # .NET
        DOTNET_CLI_HOME = "${stateHome}/dotnet";
        NUGET_PACKAGES = "${dataHome}/nuget/packages";
        NUGET_HTTP_CACHE_PATH = "${cacheHome}/nuget/http-cache";
        DOTNET_BUNDLE_EXTRACT_BASE_DIR = "${cacheHome}/dotnet/bundle";

        # Look
        LOOK_CONFIG_PATH = "${configHome}/look/config";
        LOOK_LAUNCHPAD_FILE = "${configHome}/look/super-actions.toml";
        LOOK_DB_PATH = "${dataHome}/look/look.db";
        LOOK_SOURCES_DIR = "${dataHome}/look/sources";
        LOOK_CONNECTORS_DIR = "${dataHome}/look/connectors";
        LOOK_ROWS_CACHE_DIR = "${cacheHome}/look/rows";

        # NVIDIA shader / compute caches
        __GL_SHADER_DISK_CACHE_PATH = "${cacheHome}/nvidia/GLCache";
        CUDA_CACHE_PATH = "${cacheHome}/nvidia/ComputeCache";

        # History files that otherwise land in $HOME
        LESSHISTFILE = "${stateHome}/lesshst";
        SQLITE_HISTORY = "${stateHome}/sqlite_history";
        PSQL_HISTORY = "${stateHome}/psql_history";
        MYSQL_HISTFILE = "${stateHome}/mysql_history";
      };
    in
    {
      # Export XDG_* to both login shells and the systemd user session.
      xdg.enable = true;

      home.sessionVariables = sessionVariables;
      systemd.user.sessionVariables = sessionVariables;

      home.sessionPath = [
        "${dataHome}/cargo/bin"
        "${dataHome}/go/bin"
        "${dataHome}/bun/bin"
        "${dataHome}/pnpm"
      ];

      # Move legacy dotdirs into XDG locations once. Apps that hard-code their
      # path get a compatibility symlink; apps with a working env override do
      # not. Existing targets are never overwritten.
      home.activation.xdgMigrateLegacyDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        xdg_move_dir() {
          legacy="$1"
          target="$2"
          link="$3"

          if [ -L "$legacy" ]; then
            return 0
          fi

          if [ -d "$legacy" ]; then
            if [ -e "$target" ]; then
              echo "xdg: not migrating $legacy; $target already exists" >&2
              return 0
            fi
            run mkdir -p "$(dirname "$target")"
            run mv "$legacy" "$target" || {
              echo "xdg: failed to move $legacy to $target" >&2
              return 0
            }
          fi

          if [ "$link" = 1 ] && [ -e "$target" ] && [ ! -e "$legacy" ]; then
            run ln -s "$target" "$legacy"
          fi
        }

        xdg_move_file() {
          legacy="$1"
          target="$2"

          if [ ! -e "$legacy" ] || [ -L "$legacy" ] || [ -e "$target" ]; then
            return 0
          fi

          run mkdir -p "$(dirname "$target")"
          run mv "$legacy" "$target" || true
        }

        # Supported through environment variables.
        xdg_move_dir "$HOME/.codex" "${configHome}/codex" 0

        xdg_move_dir "$HOME/.dotnet" "${stateHome}/dotnet/.dotnet" 0
        xdg_move_dir "$HOME/.emacs.d" "${configHome}/emacs" 0
        xdg_move_dir "$HOME/.gemini" "${configHome}/gemini/.gemini" 0
        # ~/.cache/nvidia/GLCache may already exist; move the subdirectories
        # individually instead of moving ~/.nv as a whole.
        xdg_move_dir "$HOME/.nv/ComputeCache" "${cacheHome}/nvidia/ComputeCache" 0
        xdg_move_dir "$HOME/.nv/GLCache" "${cacheHome}/nvidia/GLCache" 0
        if [ -d "$HOME/.nv" ] && [ ! -L "$HOME/.nv" ]; then
          run rmdir "$HOME/.nv" 2>/dev/null || true
        fi
        xdg_move_dir "$HOME/.omp" "${configHome}/omp" 0
        xdg_move_dir "$HOME/.compose-cache" "${cacheHome}/X11/xcompose" 0

        # Look keeps its config and launchpad beside each other; its DB and
        # sources have their own variables.
        xdg_move_file "$HOME/.look/config" "${configHome}/look/config"
        xdg_move_file "$HOME/.look/super-actions.toml" "${configHome}/look/super-actions.toml"
        xdg_move_file "$HOME/.look/look.db" "${dataHome}/look/look.db"
        xdg_move_dir "$HOME/.look/sources" "${dataHome}/look/sources" 0
        xdg_move_dir "$HOME/.look/connectors" "${dataHome}/look/connectors" 0
        xdg_move_dir "$HOME/.look/cache/rows" "${cacheHome}/look/rows" 0
        if [ -d "$HOME/.look" ] && [ ! -L "$HOME/.look" ]; then
          run rmdir "$HOME/.look/cache" 2>/dev/null || true
          run rmdir "$HOME/.look" 2>/dev/null || true
        fi

        # No XDG variable: keep the data in XDG and leave a compatibility link.
        xdg_move_dir "$HOME/.crashdata" "${cacheHome}/crashdata" 1

        xdg_move_dir "$HOME/.pki" "${dataHome}/pki" 1

        # Nix profiles live under $XDG_STATE_HOME with
        # use-xdg-base-directories, so a real (non-symlink) ~/.nix-profile
        # without a bin/ entry is a stale leftover.
        if [ -d "$HOME/.nix-profile" ] && [ ! -L "$HOME/.nix-profile" ] && [ ! -e "$HOME/.nix-profile/bin" ]; then
          run rm -rf "$HOME/.nix-profile"
        fi

        # Some tools require their target directory to already exist.
        run mkdir -p \
          "${configHome}/codex" \
          "${configHome}/gemini" \
          "${configHome}/look" \
          "${configHome}/omp" \
          "${stateHome}/dotnet" \
          "${dataHome}/look" \
          "${dataHome}/nuget/packages" \
          "${cacheHome}/dotnet/bundle" \
          "${cacheHome}/look/rows" \
          "${cacheHome}/nvidia" \
          "${cacheHome}/nuget/http-cache" \
          "${cacheHome}/X11/xcompose"
      '';
    };
}
