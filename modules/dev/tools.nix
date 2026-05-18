{ self, inputs, ... }:
{
  flake.nixosModules.dev =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.default ];
      home-manager.users.arc = {
        imports = [ self.homeModules.tools ];
      };
      environment.systemPackages = with pkgs; [
        fd
        zellij
        hyperfine
        tokei

        perf
        valgrind
      ];
    };

  flake.homeModules.tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # GUI Dev Applications
        github-desktop
        hoppscotch
        gitui

        # CLI Packages
        openssl
        ripgrep
        jujutsu
        jjui
        fzf
        fx
        just
        devenv
      ];
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableNushellIntegration = true;
      };
    };
}
