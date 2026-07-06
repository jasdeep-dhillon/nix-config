{ self, inputs, ... }:
{
  flake.nixosConfigurations.lain = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lain

      base
      ssh-server
      nvidia
      vcs
      programs
    ];
  };
}
