{ ... }:
{
  flake.nixosModules.settings = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "pipe-operators"
      ];
      trusted-users = [
        "@wheel"
      ];
      auto-optimise-store = true;
    };
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "26.05";
    system.disableInstallerTools = true;
  };
}
