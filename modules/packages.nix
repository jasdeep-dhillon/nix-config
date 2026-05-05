{ self, inputs, ... }:
{
  flake.nixosModules.packages =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.default ];
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
      home-manager.users.arc = {
        imports = [ self.homeModules.packages ];
      };
    };

  flake.homeModules.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        qview
        starship-jj
        gnome-calculator
        snapshot
        zathura
        kdePackages.okular
        resources
        video-trimmer
        bitwarden-desktop
        vesktop
        scrcpy
        qbittorrent
        telegram-desktop
        (discord.override {
          withVencord = true;
          # withOpenASAR = true;
        })
        loupe
        unrar
        prismlauncher
        onlyoffice-desktopeditors
        pear-desktop
        easyeffects
        jellyfin-desktop
        pinta
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
