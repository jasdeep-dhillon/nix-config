{ self, inputs, ... }:
{
  flake.nixosModules.dev = {
    imports = [ inputs.home-manager.nixosModules.default ];
    home-manager.users.arc = {
      imports = [ self.homeModules.editor ];
    };
  };
  flake.homeModules.editor =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      # IDE / Text Editors
      home.packages = with pkgs; [
        vscode-fhs
        jetbrains.clion
        # jetbrains.datagrip
        # jetbrains.idea
      ];
      programs.helix = {
        enable = true;
        settings = {
          editor = {
            line-number = "relative";
            shell = [ "nu" ];
            cursorline = true;
            lsp.display-messages = true;
            cursor-shape = {
              normal = "bar";
              insert = "bar";
              select = "block";
            };
          };
        };
      };
    };
}
