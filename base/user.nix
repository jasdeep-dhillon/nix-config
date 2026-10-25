{ self, ... }:
{
  flake.nixosModules.user =
    { pkgs, ... }:
    {
      users.users.${self.username} = {
        name = "${self.username}";
        isNormalUser = true;
        description = "${self.username}";
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
          "input"
          "kvm"
        ];
        shell = pkgs.nushell;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF3MhprJoOz8caTgMGGLq45EyXLF48RzAtwN1UJadL+"
        ];
      };
    };
}
