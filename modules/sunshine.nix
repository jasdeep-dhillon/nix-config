{ self, lib, ... }:
{
  flake.nixosModules.sunshine = {
    services.sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;
    };

    # nixpkgs' sunshine module still sets the obsolete `services.avahi.publish.*`
    # options, which emit evaluation warnings. Reset them to their null sentinel
    # and express the identical settings through the current option form.
    services.avahi = {
      publish = {
        enable = lib.mkForce null;
        userServices = lib.mkForce null;
      };
      settings.publish = {
        disable-publishing = false;
        disable-user-service-publishing = false;
        publish-addresses = true;
      };
    };
    hardware.uinput.enable = true;
    users.users.${self.username}.extraGroups = [ "uinput" ];
  };
}
