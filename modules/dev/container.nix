{ self, ... }:
{
  flake.nixosModules.dev = { pkgs, ... }: {
    imports = [ self.nixosModules.containers ];
    # Podman Helper applications
    environment.systemPackages = with pkgs; [
      podman-tui
      podman-desktop
      distrobox
      distrobox-tui
      podman-compose
    ];
  };
  flake.nixosModules.containers =
    { ... }:
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
    };
}
