{ inputs, ... }:
{
  flake.nixosModules.lanzaboote =
    { lib, config, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
      boot.loader.systemd-boot.enable = lib.mkIf config.boot.lanzaboote.enable (lib.mkForce false);

      boot.lanzaboote = {
        enable = true;
        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          enable = true;
          autoReboot = true;
        };
        pkiBundle = "/var/lib/sbctl";
      };
    };
}
