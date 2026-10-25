{ ... }:
{
  flake.nixosModules.locale = {
    time.timeZone = "America/Toronto";
    time.hardwareClockInLocalTime = true;

    i18n.defaultLocale = "en_CA.UTF-8";
  };
}
