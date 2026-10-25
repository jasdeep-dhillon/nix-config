{ self, ... }:
{
  flake.nixosModules.dev = {
    imports = [ self.nixosModules.vcs ];
  };
  flake.nixosModules.vcs =
    { pkgs, ... }:
    {
      home-manager.users.${self.username} = {
        imports = [ self.homeModules.vcs ];
      };
      programs.git = {
        enable = true;
        lfs.enable = true;
        package = pkgs.gitFull;
        config = {
          init = {
            defaultBranch = "main";
          };
        };
      };
    };

  flake.homeModules.vcs =
    { pkgs, ... }:
    let
      name = "Jasdeep-Dhillon";
      email = "jasdeepsdhillon@proton.me";
      pubkey = "~/.ssh/id_ed25519.pub";
    in
    {
      home.packages = [ pkgs.gh ];
      programs.git = {
        enable = true;
        settings = {
          user = {
            inherit email;
            inherit name;
          };
          user.signingkey = pubkey;
          gpg.format = "ssh";
          push = {
            default = "current";
            autoSetupRemote = true;
          };
          color.ui = true;
          core = {
            editor = "hx";
            autocrlf = false;
            filemode = false;
            preloadindex = true;
            fscache = true;
            longpaths = true;
          };
          gui.editor = "zeditor";
          pull.rebase = true;
          merge.conflictstyle = "zdiff3";
          rebase = {
            autosquash = true;
            autostash = true;
          };
          commit.gpgsign = true;
          commit.verbose = true;
          commit.cleanup = "scissors";
          rerere.enabled = true;
          diff = {
            algorithm = "histogram";
            colorMoved = "default";
          };
          fetch.prune = true;
          safe.directory = "/media/Storage/Projects/*";
          url = {
            "git@github.com:".insteadOf = [
              "gh:"
              "https://github.com/"
            ];
          };
        };
      };
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            inherit email;
            inherit name;
          };
          ui = {
            default-command = "log";
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = pubkey;
          };
        };
      };
    };
}
