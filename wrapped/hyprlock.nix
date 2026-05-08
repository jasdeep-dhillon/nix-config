{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.hyprlock = inputs.wrapper-modules.wrappers.hyprlock.wrap {
        inherit pkgs;
        settings = {
          general = {
            ignore_empty_input = true;
            fail_timeout = 200;
          };
          background = [
            {
              monitor = "";
              path = "${self.wallpaper}";
              blur_size = 8;
              blur_passes = 2;
              noise = 0;
            }
          ];
          input-field = {
            monitor = "";
            size = "200, 50";
            outline_thickness = 0;
            dots_size = 0.25;
            dots_spacing = 0.25;
            dots_center = true;
            dots_rounding = -1;
            outer_color = "rgb(151515)";
            inner_color = "rgb(FFFFFF)";
            font_color = "rgb(10, 10, 10)";
            # fade_on_empty = false;
            fade_timeout = 500;
            placeholder_text = "Password";
            hide_input = false;
            rounding = -1;
            check_color = "rgb(b4befe)";
            fail_color = "rgba(f38ba8)";
            fail_text = "$FAIL ($ATTEMPTS)";
            capslock_color = -1;
            numlock_color = -1;
            bothlock_color = -1;
            invert_numlock = false;
            swap_font_color = false;
            position = "0, -150";
            halign = "center";
            valign = "center";
          };
          label = [
            {
              monitor = "";
              #clock
              text = "$TIME12";
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 82;
              font_family = "Fira Semibold";
              position = "0, 350px";
              halign = "center";
              valign = "center";
              shadow_passes = 5;
              shadow_size = 10;
            }
            {
              monitor = "";
              text = ''<span text_transform="capitalize">$USER</span>'';
              color = "rgba(255, 255, 255, 1.0)";
              font_size = 30;
              font_family = "Fira Semibold";
              position = "0, -75";
              halign = "center";
              valign = "center";
              shadow_passes = 5;
              shadow_size = 10;
            }
          ];
          image = {
            monitor = "";
            path = "${self.avatar}";
            size = 240; # lesser side if not 1:1 ratio
            rounding = -1; # negative values mean circle
            border_size = 0;
            border_color = "rgb(221, 221, 221)";
            rotate = 0;
            reload_time = -1;
            position = "0, 100";
            halign = "center";
            valign = "center";
          };
        };
      };
    };
}
