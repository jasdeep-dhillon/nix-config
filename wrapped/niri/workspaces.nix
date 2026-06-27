{ ... }:
{
  flake.nixosModules.niriWorkspace = {
    settings.workspaces = {
      game = {
        open-on-output = "Lenovo Group Limited Y25g-30 #GjMYMxgwAAwA";
      };
      chat = {
        open-on-output = "BOE 0x0A9B Unknown";
      };
    };
    settings.window-rules = [
      {
        matches = [
          { app-id = "steam"; }
          { title = "Nero Manager"; }
          { app-id = "cs2"; }
          { app-id = "csgo_linux64"; }
          { app-id = "Ryujinx"; }
          { app-id = "gamescope"; }
          { app-id = "labwc"; }
          { app-id = "faugus-launcher"; }
          {
            app-id = ''
              r#"^steam_app_[0-9]*"#
            '';
          }
          { app-id = "steam_app_default"; }
        ];
        open-on-workspace = "game";
      }
      {
        matches = [ { app-id = "steam"; } ];
        open-fullscreen = false;
      }

      {
        matches = [
          { app-id = "chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Default"; }
          { app-id = "vesktop"; }
          { app-id = "discord"; }
          { app-id = "com.github.th_ch.youtube_music"; }
        ];
        open-on-workspace = "chat";
      }

      {
        matches = [
          { app-id = "com.github.th_ch.youtube_music"; }
          { app-id = "chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Default"; }
        ];
        default-column-width = {
          proportion = 0.7;
        };
      }

      {
        matches = [
          { app-id = "vesktop"; }
          { app-id = "discord"; }
        ];
        default-column-width = {
          proportion = 1.0;
        };
      }
    ];
  };
}
