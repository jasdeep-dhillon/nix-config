{ self, inputs, ... }:
{
  flake.nixosModules.dev = {
    imports = [ inputs.home-manager.nixosModules.default ];
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
        hyprls
        kdePackages.qtdeclarative
        jsonfmt
        clang-tools
      ];
    };
}
