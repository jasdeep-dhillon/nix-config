{ ... }:
{
  flake.nixosModules.qbit =
    { pkgs, ... }:
    {
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
              Password_PBKDF2 = "@ByteArray(fofM+dpr882+CmuHDEnEhQ==:AoEXHAVs9DKZgL2m8G3yycw1Em
                 │ C4WSrFhzKst4k+NzueKo4FZ4jH552vmVtYgoH+d1iDqsipEgqtXtkAC0lTSQ==)";
              ReverseProxySupportEnabled = true;
            };
          };
        };
      };
      services.cloudflare-warp.enable = true;
      environment.systemPackages = [ pkgs.cloudflare-warp ];
    };
}
