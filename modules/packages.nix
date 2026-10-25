{ self, ... }:
{
  flake.nixosModules.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        ffmpeg
        yt-dlp
        wget
        imagemagick
        uutils-coreutils-noprefix
        bottom
        eza
        zoxide
        dua
        bazaar
        yazi
        s-tui
        nix-tree
        nix-output-monitor
      ];
      home-manager.users.${self.username} = {
        imports = [ self.homeModules.packages ];
      };
    };

  flake.homeModules.packages =
    { pkgs, ... }:
    {
      home.packages =
        with pkgs;
        [
          qview
          starship-jj
          gnome-calculator
          snapshot
          mission-center
          video-trimmer
          # bitwarden-desktop
          # vesktop
          scrcpy
          qbittorrent
          telegram-desktop
          (discord.override {
            withVencord = true;
            withOpenASAR = true;
          })
          loupe
          unrar
          onlyoffice-desktopeditors
          pear-desktop
          easyeffects
          pinta
          gnome-disk-utility
          drawy
          imhex
        ]
        ++ (with pkgs.kdePackages; [
          okular
          filelight
          kdenlive
        ]);
    };
}
