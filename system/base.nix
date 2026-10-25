{ self, inputs, ... }:
{
  flake.nixosModules.base = {
    imports = with self.nixosModules; [
      tpm
      boot
      run0
      sops
      user
      locale
      services
      settings
      tailscale
      lanzaboote
      networking
      inputs.home-manager.nixosModules.default
    ];
    home-manager = {
      useUserPackages = true;
      backupFileExtension = "bak";
      overwriteBackup = true;
      users.${self.username} = {
        imports = [ self.homeModules.base ];
      };
    };
  };

  flake.homeModules.base = {
    home = {
      username = "${self.username}";
      homeDirectory = "/home/${self.username}";
      stateVersion = "26.05";
      shell.enableNushellIntegration = true;
    };
    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };
}
