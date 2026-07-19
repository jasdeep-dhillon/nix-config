{ inputs, ... }:
{
  flake.homeModules.shortcuts =
    { pkgs, lib, ... }:
    {
      xdg.desktopEntries = {
        # "windows" = {
        #   name = "Windows";
        #   categories = [ "Utility" ];
        #   comment = "Boot to Windows";
        #   exec = ''
        #     ${pkgs.systemd}/bin/systemctl reboot --boot-loader-entry=auto-windows
        #   '';
        #   icon = ../../icons/windows.ico;
        # };
        "warp-connect" = {
          name = "Warp Connect";
          categories = [ "Utility" ];
          comment = "Connect to Cloudflare Warp";
          exec = "${pkgs.networkmanager}/bin/nmcli connect up Warp";
          icon = ../../icons/openvpn.png;
        };
        "warp-disconnect" = {
          name = "Warp Disconnect";
          categories = [ "Utility" ];
          comment = "Disconnect from Cloudflare Warp";
          exec = "${pkgs.networkmanager}/bin/nmcli connect down Warp";
          icon = ../../icons/openvpn.png;
        };
        "helium-incognito" = {
          name = "Helium Incognito";
          exec = "${
            lib.getExe inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
          } --incognito";
          genericName = "Web Browser";
          icon = ../../icons/helium.png;
          terminal = false;
          type = "Application";
          categories = [
            "Network"
            "WebBrowser"
          ];
        };
      };
    };
}
