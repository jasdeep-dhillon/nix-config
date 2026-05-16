{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.fuzzel = inputs.wrapper-modules.wrappers.fuzzel.wrap {
        inherit pkgs;
        settings = {
          main = {
            terminal = lib.getExe pkgs.kitty;
            layer = "overlay";
            dpi-aware = "auto";
            show-actions = true;
            launch-prefix = lib.getExe pkgs.runapp;
            width = 60;
            # prompt = "'Search > '";
            placeholder = "Search";
            vertical-pad = 16;
            inner-pad = 8;
            line-height = 24;
            keyboard-focus = "on-demand";
          };
          colors = {
            background = "1e1e2edd";
            text = "cdd6f4ff";
            prompt = "bac2deff";
            placeholder = "7f849cff";
            input = "cdd6f4ff";
            match = "b4befeff";
            selection = "585b70ff";
            selection-text = "cdd6f4ff";
            selection-match = "b4befeff";
            counter = "7f849cff";
            border = "b4befeff";
          };
          border = {
            width = 2;
            selection-radius = 8;
          };
        };
      };
    };
}
