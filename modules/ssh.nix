{ ... }:
{
  flake.nixosModules.ssh-server =
    { ... }:
    {
      services.openssh = {
        enable = true;
        settings = {
          AllowUsers = [ "arc" ];
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    };
}
