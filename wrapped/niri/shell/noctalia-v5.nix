{ self, inputs, ... }:

{
  flake.nixosModules.niriShell =
    { pkgs, lib, ... }:
    let
      noctalia = lib.getExe inputs.noctalia-v5.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      extraPackages = [
        inputs.noctalia-v5.packages.${pkgs.stdenv.hostPlatform.system}.default
        self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
        pkgs.ddcutil
      ];
      settings = {
        spawn-at-startup = [
          [
            noctalia
            "-d"
          ]
        ];
      };
      # settings.switch-events = {
      #   lid-close = {
      #     spawn = [
      #        noctalia
      #       "ipc"
      #       "call"
      #       "toast"
      #       "send"
      #       ''
      #         { "body": "Laptop Closed", "type": "notice", "icon":"device-laptop-off" }
      #       ''
      #     ];
      #   };
      #   lid-open = {
      #     spawn = [
      #        noctalia
      #       "ipc"
      #       "call"
      #       "toast"
      #       "send"
      #       ''
      #         { "body": "Laptop Opened", "type": "notice", "icon":"device-laptop" }
      #       ''
      #     ];
      #   };
      # };
      settings.binds = {
        "Mod+F5" = {
          spawn = [ noctalia ];
        };
        "Mod+Space" = _: {
          props.cooldown-ms = 200;
          props.hotkey-overlay-title = "Launcher";
          content.spawn = [
            noctalia
            "msg"
            "panel-toggle"
            "launcher"
          ];
        };
        "Mod+V" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            noctalia
            "msg"
            "panel-toggle"
            "clipboard"
          ];
        };
        "Mod+Ctrl+Space" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Command Runner";
          content.spawn-sh = ''
            pkill -x fuzzel ||
            sh -c "$(${
              lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
            } --lines 0 -d -p 'Run: ')"
          '';
        };
        "Mod+Period" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Emoji Picker";
          content.spawn = [
            noctalia
            "msg"
            "panel-toggle"
            "launcher"
            "/emo"
          ];
        };
        # "Mod+F3" = _: {
        #   props.repeat = false;
        #   props.hotkey-overlay-title = "Audio Picker";
        #   content.spawn = [
        #     noctalia
        #     "ipc"
        #     "call"
        #     "volume"
        #     "togglePanel"
        #   ];
        # };
        "Mod+I" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Settings";
          content.spawn = [
            noctalia
            "msg"
            "settings-toggle"
          ];
        };
        "Mod+F1" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Lock Screen";
          content.spawn = [
            noctalia
            "msg"
            "screen-lock"
          ];
        };
        "Mod+Escape" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Power Menu";
          content.spawn = [
            noctalia
            "msg"
            "panel-toggle"
            "session"
          ];
        };
        "Mod+A" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Control Center";
          content.spawn = [
            noctalia
            "msg"
            "panel-toggle"
            "control-center"
          ];
        };
        # "Mod+N" = _: {
        #   props.repeat = false;
        #   props.hotkey-overlay-title = "Notifications";
        #   content.spawn = [
        #     noctalia
        #     "ipc"
        #     "call"
        #     "notifications"
        #     "toggleHistory"
        #   ];
        # };
        "Mod+Comma" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clear Notifications";
          content.spawn = [
            noctalia
            "msg"
            "notification-clear-history"
          ];
        };

        XF86MonBrightnessUp = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "brightness-up"
            "all"
            "2"
          ];
        };
        "Mod+XF86AudioRaiseVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "brightness-up"
            "all"
            "2"
          ];
        };
        "Mod+XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "brightness-down"
            "all"
            "2"
          ];
        };
        XF86MonBrightnessDown = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "brightness-down"
            "all"
            "2"
          ];
        };
        XF86AudioPlay = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "msg"
            "media"
            "toggle"
          ];
        };
        # XF86AudioStop = _: {
        #   props.allow-when-locked = true;
        #   content.spawn = [
        #     noctalia
        #     "ipc"
        #     "call"
        #     "media"
        #     "stop"
        #   ];
        # };
        XF86AudioPrev = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            "msg"
            "media"
            "previous"
          ];
        };
        XF86AudioNext = _: {
          props.allow-when-locked = true;
          content.spawn = [
            noctalia
            noctalia
            "msg"
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
