{ ... }:
{
  flake.nixosModules.qbit =
    { pkgs, config, ... }:
    {
      sops.secrets."password/qbit" = {
        owner = config.services.qbittorrent.user;
      };
      services.qbittorrent = {
        enable = true;
        user = "arc";
        webuiPort = 8098;
        profileDir = "/var/lib/qBittorrent";
        serverConfig = {
          LegalNotice.Accepted = true;
          BitTorrent = {
            Session = {
              DefaultSavePath = "/media/Storage/Downloads";
              TempPath = "${config.services.qbittorrent.profileDir}/qBittorrent/downloads/temp";
              TempPathEnabled = true;
              TorrentExportDirectory = "/media/Storage/Downloads/torrent-files";
              AnonymousModeEnabled = true;
            };
          };
          # Needs to be the last one so password can be appended
          Preferences = {
            WebUI = {
              HostHeaderValidation = false;
              Username = "arc";
              ReverseProxySupportEnabled = true;
            };
          };
        };
      };
      systemd.services.qbittorrent.serviceConfig = {
        ExecStartPre = [
          ''
            ${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/echo "WebUI\Password_PBKDF2=$(${pkgs.coreutils}/bin/cat /run/secrets/password/qbit)" >> ${config.services.qbittorrent.profileDir}/qBittorrent/config/qBittorrent.conf'
          ''
        ];
      };
      # systemd.services.cloudflare-warp.serviceConfig = {
      #   After = [ "tailscaled.service" ];
      # };
      # services.cloudflare-warp.enable = false;
      environment.systemPackages = [ pkgs.cloudflare-warp ];
    };
}
