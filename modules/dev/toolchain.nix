{ self, ... }:
{
  flake.nixosModules.dev = {
    home-manager.users.arc = {
      imports = [ self.homeModules.toolchain ];
    };
    networking.firewall = {
      allowedTCPPorts = [
        3000
        4000
      ];
      allowedUDPPorts = [
        3000
        4000
      ];
    };
  };
  flake.homeModules.toolchain =
    { pkgs, ... }:
    {
      # Language Compilers / Toolchains
      home.packages = with pkgs; [
        php
        uv
        deno
        bun
        nodejs
        rustup
        python315FreeThreading
        jdk25
        maven

        clang
        meson
      ];
    };
}
