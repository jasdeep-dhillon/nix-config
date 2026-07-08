{ ... }:
{
  flake.nixosModules.niriLayout = {
    settings.layout = {
      gaps = 4;
      always-center-single-column = { };
      center-focused-column = "never";
      background-color = "#1E1E2E";
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      preset-window-heights = [
        { proportion = 0.5; }
        { proportion = 0.6667; }
        { proportion = 1.0; }
      ];
      default-column-width = [ { proportion = 0.5; } ];
      focus-ring = {
        width = 2;
        active-color = "#8395F7";
        inactive-color = "#505050";
      };
      border = {
        off = { };
      };
      struts = {
        left = -2;
        right = -2;
        top = -2;
        bottom = -2;
      };
      tab-indicator = {
        place-within-column = { };
        gap = 4;
        width = 4;
        length = _: {
          props = {
            total-proportion = 0.99;
          };
        };
        position = "bottom";
        corner-radius = 6;
      };
      insert-hint = {
        color = "#8395F7DA";
      };
    };
  };
}
