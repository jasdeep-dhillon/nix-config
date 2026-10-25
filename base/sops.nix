{ self, inputs, ... }:
{
  flake.nixosModules.sops =
    { pkgs, config, ... }:
    let
      keyFile = "/persist/sops/keys.txt";
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [ sops ];
      sops = {
        defaultSopsFile = ../secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = keyFile;
        secrets."private_keys/ssh" = {
          path = "${config.users.users.${self.username}.home}/.ssh/id_ed25519";
          owner = config.users.users.${self.username}.name;
          mode = "0600";
        };
        secrets."private_keys/tailscale" = {
          owner = config.users.users.${self.username}.name;
        };
      };
    };
}
