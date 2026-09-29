{ ... }:
{
  flake.nixosModules.niriOutputs = {
    settings.outputs = {
      "BOE 0x0A9B Unknown" = {
        # off = {};
        mode = "2560x1600@165.004";
        scale = 1.33;
        position = _: {
          props = {
            x = 1920;
            y = 0;
          };
        };
        variable-refresh-rate = _: {
          props = {
            on-demand = true;
          };
        };
      };
      "Lenovo Group Limited Y25g-30 #GjMYMxgwAAwA" = {
        # off = {};
        mode = "1920x1080@360.113";
        scale = 1;
        position = _: {
          props = {
            x = 0;
            y = 120;
          };
        };
        variable-refresh-rate = _: {
          props = {
            on-demand = true;
          };
        };
        focus-at-startup = { };

      };
      "sunshine" = {
        # mode = "2778x1940@120";
        position = _: {
          props = {
            x = -1389;
            y = 230;
          };
        };
        scale = 2;
      };
    };
  };
}
