{ inputs, ... }:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      wrappersModules = inputs.nixpkgs.lib.mkOption {
        default = { };
      };
      wallpaper = inputs.nixpkgs.lib.mkOption {
        default = { };
      };
      avatar = inputs.nixpkgs.lib.mkOption {
        default = { };
      };
      cursorSize = inputs.nixpkgs.lib.mkOption {
        default = 18;
      };
      username = inputs.nixpkgs.lib.mkOption {
        default = "arc";
      };
    };
  };

  config = {
    systems = [
      # "aarch64-darwin"
      "aarch64-linux"
      # "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
