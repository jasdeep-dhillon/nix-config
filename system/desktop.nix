{ self, inputs, ... }:
{
  flake.nixosModules.desktop = {
    imports = with self.nixosModules; [
      niri
      flatpak
      fonts
      scheduler
      inputs.home-manager.nixosModules.default
      self.nixosModules.guiPrograms
    ];
    home-manager.users.arc = {
      imports = [ self.homeModules.desktop ];
    };
  };

  flake.homeModules.desktop = {
    imports = with self.homeModules; [
      shortcuts
      theme
    ];
    services.kdeconnect.enable = true;
  };
}
