{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
      imports = [ self.homeModules.agents ];
    };
  };
  flake.homeModules.agents = {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
    };
  };
}
