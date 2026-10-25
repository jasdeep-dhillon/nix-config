{ self, ... }:
{
  flake.nixosModules.iso =
    { lib, modulesPath, ... }:
    {
      image.modules.iso-installer = {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
          "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
          {

            boot.supportedFilesystems.zfs = lib.mkImageMediaOverride false;

            users.users.${self.username}.initialPassword = "";

            boot.lanzaboote.enable = lib.mkImageMediaOverride false;
            nixpkgs.config.cudaSupport = lib.mkImageMediaOverride false;
            boot.loader.systemd-boot.enable = lib.mkImageMediaOverride true;
          }
        ];
      };
    };
}
