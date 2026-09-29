{ ... }:
{
  flake.nixosModules.niriInput = {
    settings.input = {
      workspace-auto-back-and-forth = { };
      focus-follows-mouse = { };
      warp-mouse-to-focus = { };
      keyboard = {
        repeat-delay = 300;
        repeat-rate = 35;
      };
      touchpad = {
        # off = {};
        tap = { };
        dwt = { };
        natural-scroll = { };
        # dwtp = {};
        # drag false = {};
        # drag-lock = {};
        # accel-speed = 0.2 ;
        # accel-profile = "flat";
        # scroll-method = "two-finger";
        # disabled-on-external-mouse = {};
      };
      mouse = {
        # off = {};
        accel-profile = "flat";
        # middle-emulation = {};
        # scroll-method = "no-scroll";
      };
      touch = {
        map-to-output = "sunshine";
      };
    };
  };
}
