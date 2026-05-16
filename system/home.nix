{
  self,
  inputs,
  ...
}:
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

  flake.homeConfigurations.arc = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = with self.homeModules; [
      base
      theme
      services
      packages
      programs

      shortcuts

      # Dev
      # android
      agents
      editor
      devApps
      vcs
      toolchain
      zed
      lsp
    ];
  };
}
