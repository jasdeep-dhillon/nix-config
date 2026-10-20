{ ... }:
{
  flake.nixosModules.lain = {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
        };
        "storage" = {
          "path" = "/media/Storage";
          "valid users" = "arc";
          "force user" = "arc";
          "public" = "no";
          "writeable" = "yes";
        };
        "external" = {
          "path" = "/media/External";
          "valid users" = "arc";
          "force user" = "arc";
          "public" = "no";
          "writeable" = "yes";
        };
      };
    };
    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
      discovery = true;
    };
    services.avahi = {
      settings = {
        publish = {
          disable-publishing = false;
          disable-user-service-publishing = false;
          publish-addresses = true;
        };
      };
      nssmdns4 = true;
    };
  };

  flake.nixosModules.legion =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cifs-utils ];
      fileSystems."/media/lain/Storage" = {
        device = "//lain/storage";
        fsType = "cifs";
        options =
          let
            automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
          in
          [ "${automount_opts},uid=1000,credentials=/etc/nixos/smb-secrets" ];
      };
      fileSystems."/media/lain/External" = {
        device = "//lain/external";
        fsType = "cifs";
        options =
          let
            automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
          in
          [ "${automount_opts},uid=1000,credentials=/etc/nixos/smb-secrets" ];
      };
    };
}
