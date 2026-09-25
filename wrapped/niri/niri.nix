{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        runtimePkgs = with pkgs; [
          nirius
          (xwayland-satellite.overrideAttrs rec {
            version = "0.8.3";
            src = pkgs.fetchFromGitHub {
              owner = "Supreeeme";
              repo = "xwayland-satellite";
              hash = "sha256-eFEjCCniMCKeWU0PcZNv+tDYe08SLFPjRplyPY8OFt4=";
              rev = "v${version}";
            };
            cargoHash = "sha256-gMGFvnbxM3hD5fmkSimaFd87GEf6BXFe/MGjoS6VNVU=";
            cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
              pname = "xwayland-satellite";
              version = "add2795";
              inherit src;
              hash = "sha256-gMGFvnbxM3hD5fmkSimaFd87GEf6BXFe/MGjoS6VNVU=";
            };
          })
          jq
          kdePackages.kirigami.unwrapped
        ];
        package = pkgs.niri.overrideAttrs rec {
          src = pkgs.fetchFromGitHub {
            owner = "willybarret";
            repo = "niri";
            rev = "7fd585d";
            hash = "sha256-NmsIOdV1MW1GJ54rXOhPmD3DZJVP+c1qyim9nfWxREE=";
          };
          version = "26.04";
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            pname = pkgs.niri.pname;
            version = pkgs.niri.version;
            src = src;
            hash = "sha256-aNovCzrTtmqTO33YtZap47npdN73zXC1bap5q5dZvZk=";
          };
        };
        imports = with self.nixosModules; [
          niriInput
          niriLayout
          niriOutputs
          niriRules
          niriWorkspace

          niriBinds
          niriApplications
          niriMedia
          niriWindows
          niriStart

          niriShell
        ];
        settings = {
          prefer-no-csd = { };
          environment = {
            QT_QPA_PLATFORMTHEME = "qt6ct";
            NIXOS_OZONE_WL = "1";
            GTK_USE_PORTAL = "1";
          };
          cursor = {
            hide-when-typing = { };
          };
          overview = {
            zoom = 0.6;
            backdrop-color = "#181825";
          };
          clipboard = {
            disable-primary = { };
          };
          hotkey-overlay = {
            skip-at-startup = { };
          };
          screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";
          animations = {
            slowdown = 0.5;
          };
        };
      };
    };
}
