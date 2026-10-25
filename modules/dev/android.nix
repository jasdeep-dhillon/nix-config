{ ... }:
{
  flake.nixosModules.dev = {
    # home-manager.users.${self.username} = {
    #   imports = [ self.homeModules.android ];
    # };
  };
  flake.homeModules.android =
    { pkgs, ... }:
    {
      nixpkgs.config.android_sdk.accept_license = true;
      home.packages = with pkgs; [
        android-tools
        androidenv.androidPkgs.androidsdk
        android-studio
      ];
    };
}
