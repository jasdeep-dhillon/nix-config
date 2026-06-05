{ ... }:
{
  flake.nixosModules.user =
    { pkgs, ... }:
    {
      users.users.arc = {
        name = "arc";
        isNormalUser = true;
        description = "Arc";
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
          "input"
          "gamemode"
          "kvm"
        ];
        shell = pkgs.nushell;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMF3MhprJoOz8caTgMGGLq45EyXLF48RzAtwN1UJadL+"
        ];
      };
    };
}
