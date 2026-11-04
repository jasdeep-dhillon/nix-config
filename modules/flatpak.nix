{ ... }:
{
  flake.nixosModules.flatpak =
    { pkgs, ... }:
    let
      mountOptions = [
        "ro"
        "x-gvfs-hide"
        "resolve-symlinks"
      ];
    in
    {
      services.flatpak.enable = true;

      fonts.fontDir.enable = true;

      # Flatpak: Bind mounts /usr/share/* directories
      system.fsPackages = [ pkgs.bindfs ];

      # Fonts
      fileSystems."/usr/share/fonts" = {
        device = "/run/current-system/sw/share/X11/fonts";
        fsType = "fuse.bindfs";
        options = mountOptions;
      };

      # Icons
      fileSystems."/usr/share/icons" = {
        device = "/run/current-system/sw/share/icons";
        fsType = "fuse.bindfs";
        options = mountOptions;
      };

      # Themes
      fileSystems."/usr/share/themes" = {
        device = "/run/current-system/sw/share/themes";
        fsType = "fuse.bindfs";
        options = mountOptions;
      };
    };
}
