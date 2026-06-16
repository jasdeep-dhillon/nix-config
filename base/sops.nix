{ inputs, ... }:
{
  flake.nixosModules.sops =
    { pkgs, config, ... }:
    let
      keyFile = "/persist/sops/keys.txt";
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [ sops ];
      environment.sessionVariables = {
        SOPS_AGE_KEY_FILE = keyFile;
      };
      sops = {
        defaultSopsFile = ../secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = keyFile;
        secrets."private_keys/ssh" = {
          path = "/home/arc/.ssh/id_ed25519";
          owner = config.users.users.arc.name;
          mode = "0600";
        };
        secrets."private_keys/tailscale" = {
          owner = config.users.users.arc.name;
        };
      };
    };
}
