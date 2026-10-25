{ self, ... }:
{
  flake.nixosModules.gaming =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      boot = {
        kernel.sysctl = {
          "vm.max_map_count" = 2147483642;
          "kernel.split_lock_mitigate" = 0;
          "net.ipv4.tcp_fin_timeout" = 5;
          "kernel.sched_cfs_bandwidth_slice_us" = 3000;
        };
        kernelParams = [ "transparent_hugepage=always" ];
        kernelModules = lib.mkAfter [ "ntsync" ];
      };

      programs.steam = {
        enable = true;
        package = (
          pkgs.steam.override {
            extraEnv = {
              MANGOHUD = true;
              OBS_VKCAPTURE = true;
              PROTON_DISCORD_BRIDGE = true;
              PROTON_ENABLE_WAYLAND = true;
              PROTON_ENABLE_NTSYNC = true;
              PROTON_USE_WOW64 = true;
            }
            // (lib.optionalAttrs config.hardware.nvidia.enabled {
              __NV_PRIME_RENDER_OFFLOAD = "1";
              __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
              __VK_LAYER_NV_optimus = "NVIDIA_only";
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            });
          }
        );
        extest.enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession = {
          enable = false;
          env = {
            ENABLE_GAMESCOPE_WSI = "1";
            DXVK_HDR = "1";
          };
        };
      };
      programs.gamescope = {
        enable = true;
        capSysNice = true;
        enableWsi = true;
        args = [
          "--rt"
          "--mangoapp"
          "--adaptive-sync"
          "--expose-wayland"
        ];
      };
      programs.gamemode = {
        enable = true;
        settings = {
          general = {
            renice = 10;
            ioprio = 0;
            inhibit_screensaver = 1;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 0;
          };
        };
      };
      users.groups.gamemode.members = [ "${self.username}" ];
      environment.systemPackages = with pkgs; [
        mangohud
        sgdboop
        faugus-launcher
        protonplus
        (pkgs.prismlauncher.override {
          additionalPrograms = with pkgs; [ libxkbcommon ];
          additionalLibs = with pkgs; [ libxkbcommon ];
        })
        umu-launcher
        winetricks
        steam-run
        vulkan-tools
        ryubing
      ];
      environment.sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        PROTON_ENABLE_WAYLAND = "1";
        PROTON_ENABLE_NTSYNC = "1";
        MESA_SHADER_CACHE_MAX_SIZE = "16G";
      }
      // (lib.optionalAttrs config.hardware.nvidia.enabled {
        __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
        __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
      });

    };
}
