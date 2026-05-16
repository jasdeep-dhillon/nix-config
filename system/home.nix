{ inputs, ... }:
{
  flake.nixosModules.home =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.default ];
      home-manager = {
        useUserPackages = true;
        backupFileExtension = "bak";
        overwriteBackup = true;
        users.arc.home.stateVersion = "26.05";
      };
    };
}
