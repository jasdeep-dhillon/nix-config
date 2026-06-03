{ ... }:
{
  flake.nixosModules.flatpak =
    { pkgs, ... }:
    {
      services.flatpak.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
        ];
        configPackages = with pkgs; [ xdg-desktop-portal-gnome ];
        config.common = {
          default = [ "gnome" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
        };
      };

    };
}
