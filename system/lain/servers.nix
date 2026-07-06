{ self, ... }: {
  flake.nixosModules.lain = {
    imports = with self.nixosModules; [
      qbit
      containers
      jellyfin-server
      fluxer
    ];
  };
}
