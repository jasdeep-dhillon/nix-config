{ ... }:
{
  flake.nixosModules.niriBinds = {
    settings.binds = {
      "Mod+Shift+Slash" = {
        show-hotkey-overlay = { };
      };
      "Mod+O" = _: {
        props = {
          repeat = false;
          hotkey-overlay-title = "Pick Screenshare window";
        };
        content = {
          spawn-sh = "niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | jq .id)";
        };
      };
      "Mod+Shift+O" = _: {
        props = {
          repeat = false;
          hotkey-overlay-title = "Screenshare Current Monitor";
        };
        content = {
          set-dynamic-cast-monitor = { };
        };
      };
      "Mod+F4" = _: {
        props = {
          repeat = false;
          hotkey-overlay-title = "Unset workspace name";
        };
        content.spawn-sh = ''
          niri msg action unset-workspace-name
        '';
      };
      "Mod+F7" = _: {
        props = {
          repeat = false;
          hotkey-overlay-title = "Toggle Laptop Display";
          allow-when-locked = true;
        };
        content = {
          spawn-sh = ''
            niri msg --json outputs |
              jq -e '.["eDP-1"].current_mode != 1' &&
            niri msg --json outputs |
              jq -e '.["eDP-2"].current_mode != 0' &&
            niri msg output 'BOE 0x0A9B Unknown' on ||
            niri msg output 'BOE 0x0A9B Unknown' off
          '';
        };
      };
      "Mod+Shift+F7" = _: {
        props = {
          repeat = false;
          hotkey-overlay-title = "Toggle External Display";
          allow-when-locked = true;
        };
        content = {
          spawn-sh = ''
            niri msg --json outputs |
              jq -e '.["DP-1"].current_mode != 1' &&
              niri msg output DP-1 on ||
              niri msg output DP-1 off
          '';
        };
      };
      "Mod+Tab" = _: {
        props = {
          repeat = false;
          hotkey-overlay-title = "Toggle Overview";
        };
        content = {
          toggle-overview = { };
        };
      };
      "Mod+Shift+Q" = {
        close-window = { };
      };
      "Alt+F4" = {
        close-window = { };
      };
      "Mod+Ctrl+Q" = _: {
        props.hotkey-overlay-title = "Force Kill Selected Application";
        content.spawn-sh = "kill $(niri msg --json pick-window | jq .pid)";
      };
    };
  };
}
