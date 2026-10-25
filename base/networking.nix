{ ... }:
{
  flake.nixosModules.networking = {
    networking.networkmanager.enable = true;
    networking.firewall = {
      enable = true;
    };
  };
}
