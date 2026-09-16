{ ... }:
{
  flake.nixosModules.nvidia =
    { config, pkgs, ... }:
    {
      services.xserver.videoDrivers = [
        "nvidia"
      ];
      services.cardwired.enable = true;
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            libvdpau
            vulkan-loader
            vulkan-headers
            vulkan-validation-layers
          ];
          extraPackages32 = with pkgs.pkgsi686Linux; [
            mesa
            vulkan-loader
          ];
        };

        nvidia = {
          # package = config.boot.kernelPackages.nvidiaPackages.bleeding_edge;
          package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
            version = "615.71.09";
            sha256_64bit = "sha256-zc7tIrvrYSSNGm3qvCWWZz46ZQFpjucayNL9wo87cP4=";
            sha256_aarch64 = "sha256-IbekQhE7cFfmnPZaLY9NDYcF7CoNZ+2Qb7sRd4EOgWM=";
            openSha256 = "sha256-3gByMYIwFzRaLdDG+roCEOuKRRJDrljG9AlLnRZTirM=";
            settingsSha256 = "sha256-LK1LU8mDkM/XVRKPBtuOZh9nIP/lGFLAJnmasEX8jhg=";
            persistencedSha256 = "sha256-qPRb+3d88+2RcpUkoBTbjIaImnQ+jX+/6p1vXcJ5geE=";
          };

          modesetting.enable = true;
          powerManagement = {
            enable = true;
            # finegrained = true;
          };
          open = true;
          nvidiaSettings = true;
        };
      };
      nixpkgs.config.cudaSupport = true;
    };
}
