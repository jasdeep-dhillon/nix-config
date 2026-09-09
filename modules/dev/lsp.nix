{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
      imports = [ self.homeModules.lsp ];
    };
  };
  flake.homeModules.lsp =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nil
        nixd
    
        jsonfmt

        clang-tools #Clangd
        cmake-language-server

        vscode-langservers-extracted

        yaml-language-server

        rust-analyzer
      ];
    };
}
