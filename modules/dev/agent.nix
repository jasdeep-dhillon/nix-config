{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
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
