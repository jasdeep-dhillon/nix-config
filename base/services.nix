{ ... }:
{
  flake.nixosModules.services = {
    services.dbus.implementation = "broker";
    services.udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    services.fwupd.enable = true;
    services.upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };
    services.logind.settings.Login = {
      HandlePowerKey = "ignore";
      # HandleLidSwitch = "suspend";
    };
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
