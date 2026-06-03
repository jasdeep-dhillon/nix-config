{ self, inputs, ... }:
{
  flake.nixosModules.base = {
    imports = with self.nixosModules; [
      boot
      lanzaboote
      locale
      networking
      run0
      services
      settings
      tailscale
      user
      inputs.home-manager.nixosModules.default
    ];
    home-manager.users.arc = {
      imports = [ self.homeModules.base ];
    };
  };

  flake.homeModules.base = {
    home = {
      username = "arc";
      homeDirectory = "/home/arc";
      stateVersion = "26.05";
      shell.enableNushellIntegration = true;
    };
    nixpkgs.config.allowUnfree = true;
    programs.home-manager.enable = true;
  };
}
