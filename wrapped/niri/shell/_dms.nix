{ inputs, ... }:
{
  flake.nixosModules.niriShell =
    { pkgs, lib, ... }:
    {
      extraPackages = [ inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      settings.environment = {
        DMS_DISABLE_MATUGEN = "1";
        DMS_DISABLE_CAVA = "1";
      };
      settings.spawn-at-startup = [
        [ "echo test" ]
        #   [
        #     (lib.getExe pkgs.runapp)
        #     (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
        #     "run"
        #   ]
      ];

      settings.switch-events = {
        lid-close = {
          spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "toast"
            "info"
            "Laptop Closed"
          ];
        };
        lid-open = {
          spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "toast"
            "info"
            "Laptop Opened"
          ];
        };
      };
      settings.binds = {
        "Mod+F5" = {
          spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "run"
          ];
        };
        "Mod+Space" = _: {
          props.cooldown-ms = 200;
          props.hotkey-overlay-title = "Launcher";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "spotlight"
            "toggle"
          ];
        };
        "Mod+V" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "clipboard"
            "toggle"
          ];
        };
        "Mod+Ctrl+Space" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Clipboard";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "spotlight"
            "openQuery"
            "> "
          ];
        };
        "Mod+Period" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Emoji Picker";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "spotlight"
            "openQuery"
            ":e "
          ];
        };
        "Mod+F3" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Output Switch";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "audio"
            "cycleoutput"
          ];
        };
        "Mod+I" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Settings";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
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
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "lock"
            "lock"
          ];
        };
        "Mod+Escape" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Power Menu";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "powermenu"
            "toggle"
          ];
        };
        "Mod+A" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Control Center";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "control-center"
            "toggle"
          ];
        };
        "Mod+N" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Notifications";
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "notifications"
            "toggle"
          ];
        };

        XF86MonBrightnessUp = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "brightness"
            "increment"
            "2"
            ''""''
          ];
        };
        "Mod+XF86AudioRaiseVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "brightness"
            "increment"
            "2"
            ''""''
          ];
        };
        "Mod+XF86AudioLowerVolume" = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "brightness"
            "decrement"
            "2"
            ''""''
          ];
        };
        XF86MonBrightnessDown = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "brightness"
            "decrement"
            "2"
            ''""''
          ];
        };
        XF86AudioPlay = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "mpris"
            "playPause"
          ];
        };
        XF86AudioStop = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "mpris"
            "stop"
          ];
        };
        XF86AudioPrev = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "mpris"
            "previous"
          ];
        };
        XF86AudioNext = _: {
          props.allow-when-locked = true;
          content.spawn = [
            (lib.getExe inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "ipc"
            "call"
            "mpris"
            "next"
          ];
        };
      };
      settings.layer-rules = [
        {
          # matches = [
          #   {
          #     layer = "overlay";
          #   }
          # ];
          # background-effect = {
          #   blur = true;
          #   xray = true;
          # };
        }
      ];
    };
}
