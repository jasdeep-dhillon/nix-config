{ ... }:
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        fontconfig = {
          hinting = {
            style = "full";
          };
          defaultFonts = {
            sansSerif = [
              "Inter"
              "Roboto Flex"
            ];
            serif = [ "Noto Serif" ];
            monospace = [ "Maple Mono NL NF" ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
        enableDefaultPackages = true;
        packages = with pkgs; [
          maple-mono.NF
          maple-mono.NL-NF
          nerd-fonts.jetbrains-mono
          fira-code
          material-symbols
          inter
          geist-font
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          (google-fonts.override {
            fonts = [
              "Roboto Flex"
              "Google Sans Code"
            ];
          })
        ];
      };
    };
}
