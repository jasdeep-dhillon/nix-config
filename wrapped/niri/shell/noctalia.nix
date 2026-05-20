{ self, ... }:
{
  flake.nixosModules.ignore =
    { pkgs, lib, ... }:
    let
      noctalia = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell;
    in
    {
      runtimePkgs = [ self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell ];
      settings = {
        spawn-at-startup = [
          [
            noctalia
          ]
        ];
      };
      settings.switch-events = {
        lid-close = {
          spawn = [
            noctalia
            "ipc"
            "call"
            "toast"
            "send"
            ''
              { "body": "Laptop Closed", "type": "notice", "icon":"device-laptop-off" }
            ''
          ];
        };
        lid-open = {
          spawn = [
            noctalia
            "ipc"
            "call"
            "toast"
            "send"
            ''
              { "body": "Laptop Opened", "type": "notice", "icon":"device-laptop" }
            ''
          ];
        };
      };
      settings.binds = {
        "Mod+F5" = {
          spawn = [ noctalia ];
        };
        "Mod+Space" = _: {
          props.cooldown-ms = 200;
          props.hotkey-overlay-title = "Launcher";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "launcher"
            "toggle"
          ];
        };
        "Mod+V" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "launcher"
            "clipboard"
          ];
        };
        "Mod+Ctrl+Space" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "launcher"
            "command"
          ];
        };
        "Mod+Period" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Emoji Picker";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "launcher"
            "emoji"
          ];
        };
        "Mod+F3" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Audio Picker";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "volume"
            "togglePanel"
          ];
        };
        "Mod+I" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Settings";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "settings"
            "toggle"
          ];
        };
        "Mod+F1" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Lock Screen";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "lockScreen"
            "lock"
          ];
        };
        "Mod+Escape" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Power Menu";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "sessionMenu"
            "toggle"
          ];
        };
        "Mod+A" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Control Center";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "controlCenter"
            "toggle"
          ];
        };
        "Mod+N" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Notifications";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "notifications"
            "toggleHistory"
          ];
        };
        "Mod+Comma" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clear Notifications";
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "notifications"
            "clear"
          ];
        };

        XF86MonBrightnessUp = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "brightness"
            "increase"
          ];
        };
        "Mod+XF86AudioRaiseVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "brightness"
            "increase"
          ];
        };
        "Mod+XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "brightness"
            "decrease"
          ];
        };
        XF86MonBrightnessDown = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "brightness"
            "decrease"
          ];
        };
        XF86AudioPlay = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "media"
            "playPause"
          ];
        };
        XF86AudioStop = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "media"
            "stop"
          ];
        };
        XF86AudioPrev = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "media"
            "previous"
          ];
        };
        XF86AudioNext = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "ipc"
            "call"
            "media"
            "next"
          ];
        };
      };
      settings.layer-rules = [
        {
          matches = [
            { namespace = "^noctalia-overview*"; }
          ];
          place-within-backdrop = true;
        }
        {
          matches = [
            { namespace = "^noctalia-(background|launcher-overlay|dock)-.*$"; }
            # { namespace = "^noctalia-osd.*$"; }
            # { namespace = "^noctalia-toast.*$"; }
            # { namespace = "^noctalia-notifications.*$"; }
          ];
        }
      ];
    };
}
