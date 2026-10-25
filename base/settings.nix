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
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
      use-xdg-base-directories = true;
    };
    nixpkgs.config.allowUnfree = true;
    system.stateVersion = "26.05";
    system.disableInstallerTools = true;
  };
}
