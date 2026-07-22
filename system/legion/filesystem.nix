{ ... }:
{
  flake.nixosModules.legion = {
    fileSystems."/media/Storage" = {
      device = "/dev/disk/by-uuid/5f9c9143-71ed-486d-afec-342def106a30";
      fsType = "btrfs";
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 32 * 1024;
      }
    ];
  };
}
