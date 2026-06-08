{ self, inputs, ... }:
{
  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      base

      # Optional Modules
      theme
      bluetooth
      gaming
      nvidia
      sunshine
      udev
      desktop
      dev
      packages
      programs
      # nixld

      legion
      {
        hardware = {
          nvidia = {
            dynamicBoost.enable = true;
            powerManagement.finegrained = true;
            nvidiaPersistenced = true;
            prime = {
              amdgpuBusId = "PCI:53:0:0";
              nvidiaBusId = "PCI:1:0:0";
              offload = {
                enable = true;
                enableOffloadCmd = true;
              };
            };
          };
        };
        services.hardware.openrgb.enable = true;
        powerManagement.enable = true;
      }
    ];
  };
}
