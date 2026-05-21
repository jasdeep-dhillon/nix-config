{ ... }:
{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      hardware.graphics.enable32Bit = true;
      programs.steam = {
        enable = true;
        package = (
          pkgs.steam.override {
            extraEnv = {
              MANGOHUD = true;
            };
          }
        );
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true;
        # gamescopeSession.enable = true;
      };
      programs.gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "--rt"
          "--mangoapp"
          "--adaptive-sync"
          "-O DP-5,eDP-1"
          "-r 360"
          # "--prefer-vk-device 8086:9bc4"
        ];
        env = # for Prime render offload on Nvidia laptops.
          # Also requires `hardware.nvidia.prime.offload.enable`.
          {
            __NV_PRIME_RENDER_OFFLOAD = "1";
            __VK_LAYER_NV_optimus = "NVIDIA_only";
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          };
      };
      programs.gamemode.enable = true;
      environment.systemPackages = with pkgs; [
        gamescope-wsi
        mangohud
        sgdboop
        winetricks
        wineWow64Packages.unstableFull
        nero-umu
        faugus-launcher
        protonplus
        (pkgs.prismlauncher.override {
          additionalPrograms = with pkgs; [ libxkbcommon ];
          additionalLibs = with pkgs; [ libxkbcommon ];
          
        })
        # umu-launcher
        # wineWowPackages.staging
        ryubing
      ];
      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATH = "\${HOME}/.steam/root/compatibilitytools.d";
      };
    };
}
