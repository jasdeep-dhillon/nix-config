{ ... }:
{
  flake.nixosModules.nvidia =
    { config, pkgs, ... }:
    {
      services.xserver.videoDrivers = [
        "nvidia"
      ];
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
          package = config.boot.kernelPackages.nvidiaPackages.bleeding_edge;
          # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          #   version = "595.45.04";
          #   sha256_64bit = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
          #   sha256_aarch64 = "sha256-jl6lQWsgF6ya22sAhYPpERJ9r+wjnWzbGnINDpUMzsk=";
          #   openSha256 = "sha256-uqNfImwTKhK8gncUdP1TPp0D6Gog4MSeIJMZQiJWDoE=";
          #   settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
          #   persistencedSha256 = "sha256-5FoeUaRRMBIPEWGy4Uo0Aho39KXmjzQsuAD9m/XkNpA=";
          # };

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
