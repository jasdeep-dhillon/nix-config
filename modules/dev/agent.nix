{ self, inputs, ... }:
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
    home.packages = [
      pkgs.opencode-desktop
      self.packages.${pkgs.stdenv.hostPlatform.system}.tern
      inputs.autolith.packages.${pkgs.stdenv.hostPlatform.system}.autolith
    ];
  };
}
