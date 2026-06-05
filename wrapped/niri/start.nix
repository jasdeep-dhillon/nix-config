{ ... }:
{
  flake.nixosModules.niriStart =
    { pkgs, lib, ... }:
    {
      settings = {
        spawn-at-startup = [
          [
            # (lib.getExe pkgs.runapp)
            "${pkgs.nirius}/bin/niriusd"
          ]
          [
            # (lib.getExe pkgs.runapp)
            "steam"
          ]
          [
            # (lib.getExe pkgs.runapp)
            (lib.getExe pkgs.pear-desktop)
          ]
        ];
        # spawn-sh-at-startup = [
        #   ''
        #     sleep 5;
        #     ${lib.getExe pkgs.runapp}
        #     ${lib.getExe pkgs.vesktop}
        #   ''
        #   # ''
        #   #   sleep 5;
        #   #   ${lib.getExe pkgs.runapp}
        #   #   ${lib.getExe pkgs.easyeffects}
        #   # ''
        # ];
      };
    };
}
