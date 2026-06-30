{ self, ... }:
{
  flake.nixosModules.dev = {
    imports = [ self.nixosModules.containers ];
  };
  flake.nixosModules.containers =
    { pkgs, ... }:
    {
      # Enable Containers using Podman
      virtualisation = {
        containers.enable = true;
        oci-containers.backend = "podman";
        podman = {
          enable = true;
          autoPrune.enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings = {
            dns_enabled = true;
          };
        };
      };
      # Podman Helper applications
      environment.systemPackages = with pkgs; [
        podman-compose
        podman-tui
        podman-desktop
        distrobox
        distrobox-tui
      ];
    };
}
