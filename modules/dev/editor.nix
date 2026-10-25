{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.${self.username} = {
      imports = [
        self.homeModules.editor
      ];
    };
  };
  flake.homeModules.editor =
    { pkgs, ... }:
    {
      # IDE
      home.packages = with pkgs; [
        self.packages.${pkgs.stdenv.hostPlatform.system}.mitos
        # vscode-fhs
        # jetbrains.clion
        # jetbrains.datagrip
        # jetbrains.idea
      ];
    };
}
