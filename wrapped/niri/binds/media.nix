{ ... }:
{
  flake.nixosModules.niriMedia = {
    settings.binds = {
      XF86AudioRaiseVolume = _: {
        props.allow-when-locked = true;
        content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+ -l 1.0";
      };
      XF86AudioLowerVolume = _: {
        props.allow-when-locked = true;
        content.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-";
      };
      XF86AudioMute = _: {
        props.allow-when-locked = true;
        content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      XF86AudioMicMute = _: {
        props.allow-when-locked = true;
        content.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
    };
  };
}
