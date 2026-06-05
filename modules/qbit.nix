{ ... }:
{
  flake.nixosModules.qbit =
    { pkgs, config, ... }:
    {
      sops.secrets."password/qbit" = {
        owner = config.users.users.arc.name;
      };
      services.qbittorrent = {
        enable = true;
        user = "arc";
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent = {
            Session = {
              DefaultSavePath = "/media/Storage/Downloads";
              TempPath = "/var/lib/qBittorrent/qBittorrent/downloads/temp";
              TempPathEnabled = true;
              TorrentExportDirectory = "/media/Storage/Downloads/torrent-files";
              AnonymousModeEnabled = true;
            };
          };
          Preferences = {
            WebUI = {
              Username = "arc";
              Password_PBKDF2 = builtins.readFile config.sops.secrets."password/qbit".path;
              ReverseProxySupportEnabled = true;
            };
          };
        };
      };
      services.cloudflare-warp.enable = true;
      environment.systemPackages = [ pkgs.cloudflare-warp ];
    };
}
