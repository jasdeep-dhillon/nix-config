{ ... }:
{
  flake.nixosModules.boot =
    { pkgs, ... }:
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
        loader.timeout = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
          "plymouth.use-simpledrm=0"
        ];
        kernelModules = [ "ntsync" ];
        supportedFilesystems = {
          btrfs = true;
          ntfs = true;
        };
      };
    };

}
