{ self, inputs, ... }:
{
  flake.nixosConfigurations.lain = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      lain
      
      base
      ssh-server
      jellyfin-server
      nvidia
      vcs
      programs
      qbit
    ];
  };
}
