{ self, ... }:
{
  flake.nixosModules.tpm = {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
    users.users.${self.username}.extraGroups = [ "tss" ];
  };
}
