{ ... }:
{
  flake.nixosModules.settings = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "26.05";
  };
}
