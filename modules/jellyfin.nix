{ ... }:
{
  flake.nixosModules.jellyfin-server =
    { pkgs, ... }:
    {
      services.jellyfin = {
        enable = true;
        user = "arc";
      };
      environment.systemPackages = with pkgs; [
        jellyfin
        jellyfin-web
        jellyfin-ffmpeg
      ];
    };

  flake.nixosModules.jellyfin-client =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.jellyfin-desktop ];
    };
}
