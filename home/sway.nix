{ settings, lib, config, ... }:
let
  mod = "Mod4";
  # stylix's sway target uses base0D for focused and base0B for the indicator, the mismatched
  # colors this overrides.
  # indicator is the edge highlight for where the next window opens, forced equal to the
  # border here, never a separate color.
  c = config.lib.stylix.colors.withHashtag;
  focusedColor = c.base0F; # brown
  unfocusedColor = c.base02; # selection-bg
  urgentColor = c.base08; # red
  windowColors =
    { border }:
    {
      inherit border;
      childBorder = border;
      indicator = border;
      background = c.base00;
      text = c.base05;
    };
in
{
  # sway base. per-host monitor layout lives in hosts/<host>/home.nix.
  # the session launch is system level (modules/desktop.nix), not here.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway.enable
    config = {
      modifier = mod;
      terminal = "foot";
      menu = "fuzzel"; # Super+D launcher (native wayland, no xwayland)
      startup = [
        # import session vars so user services (polkit agents, etc.) see the wayland socket and session id
        { command = "systemctl --user import-environment XDG_SESSION_ID XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY"; }
        { command = "waybar"; }
        { command = "sway-autotile"; }
        # wallpaper file stays out of the repo (licensing), the glob takes any png/jpg/jpeg
        { command = ''swaybg -m fill -i "$(ls /home/${settings.username}/Pictures/wallpaper.* 2>/dev/null | head -n1)"''; }
        # store clipboard history, skipping file-manager copies (they land as a useless path/uri)
        { command = "wl-paste --watch sh -c 'wl-paste --list-types | grep -q gnome-copied-files || cliphist store'"; }
      ];
      bars = [ ]; # waybar runs from startup, drop the default swaybar

      colors = lib.mkForce {
        background = c.base00;
        focused = windowColors { border = focusedColor; };
        focusedInactive = windowColors { border = unfocusedColor; };
        unfocused = windowColors { border = unfocusedColor; };
        placeholder = windowColors { border = unfocusedColor; };
        urgent = windowColors { border = urgentColor; };
      };

      input."type:keyboard" = {
        repeat_delay = "200"; # ms before a held key starts repeating
        repeat_rate = "60";   # repeats per second once it kicks in
      };

      window = {
        border = 3;
        titlebar = false;
        commands = [
          {
            # foot sets app_id at map time and it never changes, so match on it not title.
            criteria.app_id = "popup-terminal";
            command = "floating enable, resize set 800 500, move position center";
          }
          {
            criteria.app_id = "satty";
            command = "floating enable, resize set 1600 900, move position center";
          }
          {
            criteria.app_id = "thunar";
            command = "floating enable, resize set 1200 750, move position center";
          }
          # no dialog float rule needed. sway already auto-floats modal, transient, fixed-size and _NET_WM_WINDOW_TYPE dialog/utility/toolbar/splash windows.
        ];
      };

      # floating windows match tiled: same 4px border, no titlebar
      floating = {
        border = 3;
        titlebar = false;
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+v"             = "splith"; # vertical line, tiles side by side
        "${mod}+b"             = "splitv"; # horizontal line, tiles top/bottom
        "${mod}+Shift+e"       = "exec powermenu"; # power menu, replaces the default exit nag
        "${mod}+c"             = "exec bash -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'";
        "Print"                = "exec grim - | satty --filename -";
        "Shift+Print"          = "exec grim -g \"$(slurp)\" - | satty --filename -";
        "XF86AudioPlay"        = "exec playerctl play-pause";
        "XF86AudioPause"       = "exec playerctl play-pause";
        "XF86AudioNext"        = "exec playerctl next";
        "XF86AudioPrev"        = "exec playerctl previous";
        "XF86AudioStop"        = "exec playerctl stop";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute"        = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute"     = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
    };
    extraConfig = ''
      # disables the middle-click primary-selection buffer wayland-wide (config-load only, swaymsg rejects it at runtime)
      primary_selection disabled
      corner_radius 6
      shadows enable
      gaps inner 3
      gaps outer 1
    '';
  };
}
