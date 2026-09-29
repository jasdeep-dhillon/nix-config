{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
      imports = [
        self.homeModules.editor
      ];
    };
  };
  flake.homeModules.editor =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
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
