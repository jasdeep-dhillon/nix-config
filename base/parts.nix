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
    };
  };

  config = {
    systems = [
      # "aarch64-darwin"
      "aarch64-linux"
      # "x86_64-darwin"
      "x86_64-linux"
    ];
    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
  };
}
