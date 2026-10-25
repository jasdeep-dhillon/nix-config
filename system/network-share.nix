{ self, ... }:
{
  flake.nixosModules.lain = { lib, ... }: {
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
          "valid users" = "${self.username}";
          "force user" = "${self.username}";
          "public" = "no";
          "writeable" = "yes";
        };
        "external" = {
          "path" = "/media/External";
          "valid users" = "${self.username}";
          "force user" = "${self.username}";
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
      publish = {
        enable = lib.mkForce null;
        userServices = lib.mkForce null;
      };
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
    { pkgs, config, ... }:
    let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=120,x-systemd.device-timeout=5s,x-systemd.mount-timeout=15s";
      uid = config.users.users.${self.username}.uid;
    in
    {
      sops.secrets."password/smb" = { };
      sops.templates."smb-credentials" = {
        mode = "0400";
        content = ''
          username=${self.username}
          password=${config.sops.placeholder."password/smb"}
        '';
      };
      environment.systemPackages = [ pkgs.cifs-utils ];
      fileSystems."/media/lain/Storage" = {
        device = "//lain/storage";
        fsType = "cifs";
        options = [
          "${automount_opts},uid=${toString uid},credentials=${config.sops.templates."smb-credentials".path}"
        ];
      };
      fileSystems."/media/lain/External" = {
        device = "//lain/external";
        fsType = "cifs";
        options = [
          "${automount_opts},uid=${toString uid},credentials=${config.sops.templates."smb-credentials".path}"
        ];
      };
    };
}
