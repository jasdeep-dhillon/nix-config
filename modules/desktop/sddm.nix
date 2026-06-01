{ self, ... }:
{
  flake.nixosModules.sddm =
    { pkgs, lib, ... }:
    let
      background-package = pkgs.stdenvNoCC.mkDerivation {
        name = "background-image";
        src = self.wallpaper;
        dontUnpack = true;
        installPhase = ''
          cp $src $out
        '';
      };
      avatar-package = pkgs.stdenvNoCC.mkDerivation {
        name = "avatar-package";
        src = self.avatar;
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out/share/sddm/faces
          cp $src $out/share/sddm/faces/arc.face.icon
        '';
      };
    in
    {
      services.displayManager.sddm = {
        enable = true;
        theme = lib.mkForce "breeze";
        wayland.enable = true;
        wayland.compositor = "kwin";
        extraPackages = with pkgs.kdePackages; [
          kirigami
          libplasma
          # plasma5support
          qtsvg
          plasma-desktop
          plasma-workspace
          breeze
          breeze-icons
          qtvirtualkeyboard
        ];
      };
      environment.systemPackages = with pkgs.kdePackages; [
        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background="${background-package}"
        '')
        avatar-package
        plasma-desktop
      ];
    };
}
