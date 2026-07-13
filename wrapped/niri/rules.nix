{ ... }:
{
  flake.nixosModules.niriRules = {
    settings.window-rules = [
      {
        background-effect = {
          blur = true;
          xray = true;
        };
      }
      {
        matches = [ { is-floating = true; } ];
        shadow = {
          on = { };
        };
      }
      {
        matches = [
          { app-id = "org.freedesktop.impl.portal.desktop.kde"; }
          {
            app-id = "org.quickshell";
            title = "Noctalia";
          }
          { app-id = "chrome-nngceckbapebfimnlniiiahkandclblb-Default"; }
          { app-id = ''r#"org\.kde\.ark"# title="File Already Exists"''; }
          {
            app-id = "steam";
            title = ''r#"notificationstoasts.*"#'';
          }
        ];
        open-floating = true;
      }
      {
        matches = [
          { title = "^Picture-in-picture$"; }
          { app-id = ''r#"firefox$"# title="^Picture-in-Picture$"''; }
        ];
        open-floating = true;
        focus-ring = {
          off = { };
        };
      }
      {
        matches = [
          { app-id = "mpv"; }
        ];
        variable-refresh-rate = true;
        default-column-width = [ ];
      }
      {
        matches = [
          { app-id = "org.qbittorrent.qBittorrent"; }
        ];
        default-column-width = [ { proportion = 0.7; } ];
      }
      {
        matches = [ { app-id = "^wiremix$"; } ];
        default-floating-position = _: {
          props = {
            x = 0;
            y = 300;
            relative-to = "top";
          };
        };
        default-window-height = [
          {
            proportion = 0.5;
          }
        ];
        default-column-width = [
          {
            proportion = 0.5;
          }
        ];
        open-floating = true;
      }
      {
        matches = [
          { app-id = ''r#"^steam$"#''; }
          { title = "Error"; }
          { title = "Setup"; }
        ];
        open-fullscreen = false;
      }
      {
        excludes = [
          { app-id = ''r#"^steam$"#''; }
          { title = "Error"; }
          { title = "^$"; }
        ];
        matches = [
          { title = "StellarBlade  "; }
          { title = "Overwatch"; }
          { title = "Marvel Rivals"; }
          { title = "Glace"; }
          { title = "Clair Obscur: Expedition 33  "; }
          { app-id = ''r#"^steam_app_[0-9]*"#''; }
          { title = "Assassin's Creed IV Black Flag"; }
          { app-id = "gamescope"; }
          { app-id = "Minecraft"; }
          { app-id = "steam_app_default"; }
        ];
        open-fullscreen = true;
        open-floating = false;
      }
      {
        matches = [
          {
            app-id = "steam";
            title = "^notificationtoasts_\\d+_desktop$";
          }
        ];
        default-floating-position = _: {
          props = {
            x = 10;
            y = 10;
            relative-to = "bottom-right";
          };
        };
      }
      {
        matches = [
          { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
          { app-id = "^org\\.gnome\\.World\\.Secrets$"; }
          { app-id = "Bitwarden"; }
        ];
        block-out-from = "screen-capture";
        /*
          Use this instead if you want them visible on third-party screenshot tools.
          block-out-from = "screencast";
        */
      }
      {
        matches = [
          { app-id = "vesktop"; }
        ];
        block-out-from = "screencast";
      }
      {
        matches = [ { is-window-cast-target = true; } ];
        focus-ring = {
          active-color = "#EAB387";
        };
      }
      {
        geometry-corner-radius = 4;
        clip-to-geometry = true;
      }
    ];
  };
}
