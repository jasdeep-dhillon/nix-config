{ ... }:
{
  flake.nixosModules.window-manager =
    { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        wiremix
        wl-clipboard
        hyprpicker
        runapp
        quickshell
        nautilus
        kdePackages.ark
        kdePackages.dolphin
      ];
      environment.etc."/xdg/menus/applications.menu".text =
        builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      xdg.portal.enable = true;
      xdg.mime.enable = true;
      xdg.menus.enable = true;
    };
}
