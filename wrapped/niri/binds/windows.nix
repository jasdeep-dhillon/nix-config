{ ... }:
{
  flake.nixosModules.niriWindows = {
    settings.binds = {
      # Focus
      "Mod+H" = {
        focus-column-left = { };
      };
      "Mod+J" = {
        focus-window-down = { };
      };
      "Mod+K" = {
        focus-window-up = { };
      };
      "Mod+L" = {
        focus-column-right = { };
      };
      "Mod+Home" = {
        focus-column-first = { };
      };
      "Mod+End" = {
        focus-column-last = { };
      };

      # Workspace Focus
      "Mod+Page_Up" = {
        focus-workspace-up = { };
      };
      "Mod+Page_Down" = {
        focus-workspace-down = { };
      };
      "Mod+Ctrl+K" = {
        focus-workspace-up = { };
      };
      "Mod+Ctrl+J" = {
        focus-workspace-down = { };
      };

      # Monitor Focus
      "Mod+Left" = {
        focus-monitor-left = { };
      };
      "Mod+Down" = {
        focus-monitor-down = { };
      };
      "Mod+Up" = {
        focus-monitor-up = { };
      };
      "Mod+Right" = {
        focus-monitor-right = { };
      };

      # Move Windows
      "Mod+Shift+H" = {
        move-column-left = { };
      };
      "Mod+Shift+J" = {
        move-window-down = { };
      };
      "Mod+Shift+K" = {
        move-window-up = { };
      };
      "Mod+Shift+L" = {
        move-column-right = { };
      };
      "Mod+Shift+Home" = {
        move-column-to-first = { };
      };
      "Mod+Shift+End" = {
        move-column-to-last = { };
      };

      # Move Windows between Monitors
      "Mod+Shift+Left" = {
        move-column-to-monitor-left = { };
      };
      "Mod+Shift+Down" = {
        move-column-to-monitor-down = { };
      };
      "Mod+Shift+Up" = {
        move-column-to-monitor-up = { };
      };
      "Mod+Shift+Right" = {
        move-column-to-monitor-right = { };
      };

      # Move Windows between Workspaces
      "Mod+Shift+Page_Down" = {
        move-column-to-workspace-down = { };
      };
      "Mod+Shift+Page_Up" = {
        move-column-to-workspace-up = { };
      };

      # Move Workspace
      "Mod+Ctrl+Page_Up" = {
        move-workspace-up = { };
      };
      "Mod+Ctrl+Page_Down" = {
        move-workspace-down = { };
      };

      # Move Workspace between Monitors
      "Mod+Ctrl+Left" = {
        move-workspace-to-monitor-left = { };
      };
      "Mod+Ctrl+Right" = {
        move-workspace-to-monitor-right = { };
      };
      "Mod+Ctrl+Up" = {
        move-workspace-to-monitor-up = { };
      };
      "Mod+Ctrl+Down" = {
        move-workspace-to-monitor-left = { };
      };

      # Mouse Assisted
      "Mod+WheelScrollDown" = _: {
        props.cooldown-ms = 100;
        content.focus-workspace-down = { };
      };
      "Mod+WheelScrollUp" = _: {
        props.cooldown-ms = 100;
        content.focus-workspace-up = { };
      };
      "Mod+Ctrl+WheelScrollDown" = _: {
        props.cooldown-ms = 100;
        content.move-column-to-workspace-down = { };
      };
      "Mod+Ctrl+WheelScrollUp" = _: {
        props.cooldown-ms = 100;
        content.move-column-to-workspace-up = { };
      };

      "Mod+WheelScrollRight" = {
        focus-column-right = { };
      };
      "Mod+WheelScrollLeft" = {
        focus-column-left = { };
      };
      "Mod+Ctrl+WheelScrollRight" = {
        move-column-right = { };
      };
      "Mod+Ctrl+WheelScrollLeft" = {
        move-column-left = { };
      };

      "Mod+Shift+WheelScrollDown" = {
        focus-column-right = { };
      };
      "Mod+Shift+WheelScrollUp" = {
        focus-column-left = { };
      };
      "Mod+Ctrl+Shift+WheelScrollDown" = {
        move-column-right = { };
      };
      "Mod+Ctrl+Shift+WheelScrollUp" = {
        move-column-left = _: { };
      };

      # Direct workspace focus
      "Mod+1" = {
        focus-workspace = 1;
      };
      "Mod+2" = {
        focus-workspace = 2;
      };
      "Mod+3" = {
        focus-workspace = 3;
      };
      "Mod+4" = {
        focus-workspace = 4;
      };
      "Mod+5" = {
        focus-workspace = 5;
      };
      "Mod+6" = {
        focus-workspace = 6;
      };
      "Mod+7" = {
        focus-workspace = 7;
      };
      "Mod+8" = {
        focus-workspace = 8;
      };
      "Mod+9" = {
        focus-workspace = 9;
      };

      # Direct window move
      "Mod+Shift+1" = {
        move-window-to-workspace = 1;
      };
      "Mod+Shift+2" = {
        move-window-to-workspace = 2;
      };
      "Mod+Shift+3" = {
        move-window-to-workspace = 3;
      };
      "Mod+Shift+4" = {
        move-window-to-workspace = 4;
      };
      "Mod+Shift+5" = {
        move-window-to-workspace = 5;
      };
      "Mod+Shift+6" = {
        move-window-to-workspace = 6;
      };
      "Mod+Shift+7" = {
        move-window-to-workspace = 7;
      };
      "Mod+Shift+8" = {
        move-window-to-workspace = 8;
      };
      "Mod+Shift+9" = {
        move-window-to-workspace = 9;
      };

      # Consume / expel
      "Mod+BracketLeft" = {
        consume-or-expel-window-left = { };
      };
      "Mod+BracketRight" = {
        consume-or-expel-window-right = { };
      };

      # Window Sizing
      "Mod+R" = {
        switch-preset-column-width = { };
      };
      "Mod+Shift+R" = {
        switch-preset-window-height = { };
      };
      "Mod+W" = {
        maximize-column = { };
      };
      "Mod+Shift+W" = {
        maximize-window-to-edges = { };
      };
      "Mod+S" = {
        fullscreen-window = { };
      };
      "Mod+Shift+S" = {
        toggle-windowed-fullscreen = { };
      };
      "Mod+Minus" = {
        set-column-width = "-5%";
      };
      "Mod+Equal" = {
        set-column-width = "+5%";
      };

      "Mod+Shift+Minus" = {
        set-window-height = "-5%";
      };
      "Mod+Shift+Equal" = {
        set-window-height = "+5%";
      };

      "Mod+F" = {
        toggle-window-floating = { };
      };
      "Mod+Shift+F" = {
        switch-focus-between-floating-and-tiling = { };
      };
      "Mod+G" = {
        toggle-column-tabbed-display = { };
      };
    };
  };
}
