{ ... }:
{
  flake.nixosModules.niriApplications =
    { pkgs, lib, ... }:
    {
      settings.binds = {

        "Mod+T" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Kitty";
          content.spawn = [
            (lib.getExe pkgs.kitty)
          ];
        };
        "Mod+E" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "File Manager";
          content.spawn = [
            "${pkgs.kdePackages.dolphin}/bin/dolphin"
          ];
        };
        "Mod+B" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Helium";
          content.spawn = [
            # (lib.getExe inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "helium"
          ];
        };
        "Mod+Shift+B" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Incognito";
          content.spawn = [
            # (lib.getExe inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default)
            "helium"
            "--incognito"
          ];
        };
        "Mod+M" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Youtube Music";
          content.spawn = [
            (lib.getExe pkgs.nirius)
            "focus-or-spawn"
            "--app-id"
            "com.github.th_ch.youtube_music"
            (lib.getExe pkgs.pear-desktop)
          ];
        };
        "Mod+Z" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Zed";
          content.spawn = [
            (lib.getExe pkgs.zed-editor)
          ];
        };
        "Ctrl+Shift+Escape" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Bottom";
          content.spawn = [
            (lib.getExe pkgs.kitty)
            "-e"
            (lib.getExe pkgs.bottom)
          ];
        };
        # "Mod+Slash" = _: {
        #   props.repeat = false;
        #   props.hotkey-overlay-title = "Bitwarden";
        #   content.spawn = [
        #     (lib.getExe pkgs.bitwarden-desktop)
        #   ];
        # };
        "Mod+Shift+Escape" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Quit Niri";
          content.quit = _: { };
        };
        "Mod+Shift+M" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Wiremix";
          content.spawn = [
            (lib.getExe pkgs.kitty)
            "--class=wiremix"
            "-e"
            (lib.getExe pkgs.wiremix)
          ];
        };
        # Screenshot
        "Mod+Print" = _: {
          props.hotkey-overlay-title = "Screen Screenshot";
          content.screenshot-screen = _: {
            props.write-to-disk = false;
          };
        };
        "Mod+Ctrl+Print" = _: {
          props.hotkey-overlay-title = "Screen Screenshot";
          content.screenshot-screen = _: { };
        };
        "Print" = {
          screenshot = { };
        };
        "Alt+Print" = {
          screenshot-window = _: {
            props.write-to-disk = false;
          };
        };
        "Alt+Ctrl+Print" = {
          screenshot-window = { };
        };
        "Mod+Shift+C" = _: {
          props.repeat = false;
          props.hotkey-overlay-title = "Color Picker";
          content.spawn-sh = " ${lib.getExe pkgs.hyprpicker} | wl-copy";
        };
      };
    };
}
