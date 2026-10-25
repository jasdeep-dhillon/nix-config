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
            ${pkgs.bash}/bin/sh -c 'conf="${config.services.qbittorrent.profileDir}/qBittorrent/config/qBittorrent.conf"; pw="$(${pkgs.coreutils}/bin/cat /run/secrets/password/qbit)"; ${pkgs.gnused}/bin/sed -i "/WebUI\\\\Password_PBKDF2=/d" "$conf"; ${pkgs.coreutils}/bin/echo "WebUI\Password_PBKDF2=$pw" >> "$conf"'
          ''
        ];
      };
    };
}
