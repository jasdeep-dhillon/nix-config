{ self, ... }:
{
  flake.nixosModules.lain =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      environment.systemPackages = with pkgs; [
        self.packages.${pkgs.stdenv.hostPlatform.system}.mitos
        just
        devenv
      ];
      hardware = {
        graphics.extraPackages = with pkgs; [ intel-media-driver ];
        nvidia = {
          open = lib.mkForce false;
          package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.legacy_580;
          powerManagement.enable = lib.mkForce false;
          nvidiaPersistenced = true;
          prime = {
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
          };
        };
        enableAllFirmware = true;
      };
      services.logind.settings.Login.HandleLidSwitch = "ignore";
      services.upower.allowRiskyCriticalPowerAction = true;
      services.upower.criticalPowerAction = lib.mkForce "Ignore";
      powerManagement.enable = true;
    };
}
