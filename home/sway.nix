{ settings, lib, ... }:
let
  mod = "Mod4";
in
{
  # the border colors below are hand-tuned, stylix stays out of the sway config
  stylix.targets.sway.enable = false;

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

      input."type:keyboard" = {
        repeat_delay = "200"; # ms before a held key starts repeating
        repeat_rate = "60";   # repeats per second once it kicks in
      };

      window = {
        border = 4;
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
          # no dialog float rule needed. sway already auto-floats modal, transient, fixed-size and _NET_WM_WINDOW_TYPE dialog/utility/toolbar/splash windows.
        ];
      };

      # floating windows match tiled: same 4px border, no titlebar
      floating = {
        border = 4;
        titlebar = false;
      };

      colors = {
        focused = {
          border      = "#6A5535";
          background  = "#6A5535";
          text        = "#ffffff";
          indicator   = "#6A5535";
          childBorder = "#6A5535";
        };
        unfocused = {
          border      = "#3A2210";
          background  = "#3A2210";
          text        = "#888888";
          indicator   = "#3A2210";
          childBorder = "#3A2210";
        };
        focusedInactive = {
          border      = "#3A2210";
          background  = "#3A2210";
          text        = "#888888";
          indicator   = "#3A2210";
          childBorder = "#3A2210";
        };
        urgent = {
          border      = "#cc3333";
          background  = "#cc3333";
          text        = "#ffffff";
          indicator   = "#cc3333";
          childBorder = "#cc3333";
        };
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
