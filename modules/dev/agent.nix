{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.${self.username} = {
      imports = [ self.homeModules.agents ];
    };
  };
  flake.homeModules.agents = { pkgs, ... }: {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
    };
    home.packages = [ pkgs.opencode-desktop ];
  };
}
