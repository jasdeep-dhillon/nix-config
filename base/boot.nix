{ self, ... }:
{
  flake.nixosModules.base = {
    imports = [ self.nixosModules.boot ];
  };
  flake.nixosModules.boot =
    { pkgs, lib, ... }:
    {
      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        plymouth = {
          enable = true;
          extraConfig = ''
            DeviceScale=1
          '';
        };

        loader.systemd-boot.configurationLimit = 10;

        # Silent Boot
        consoleLogLevel = 3;
        loader.timeout = lib.mkDefault 0;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
          "plymouth.use-simpledrm=0"
        ];
        kernelModules = lib.mkAfter [ "ntsync" ];
        supportedFilesystems = {
          btrfs = true;
          ntfs = true;
        };
      };
    };

}
