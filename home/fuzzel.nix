{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    package = null; # fuzzel is installed system-wide, home-manager only writes the config
    # fuzzel runs Terminal=true apps in xterm by default, xterm isn't installed here.
    # foot takes the command as trailing args, so no -e, just "foot".
    settings.main.terminal = "foot";
  };

  # power menu, launched from Mod+Shift+e, the waybar button and the fuzzel entry.
  # fuzzel --dmenu draws the four actions, its own config so the main launcher is untouched.
  # no logout entry, autologin has nowhere to return to.
  # an overlay not a window, so no sway float rule needed.
  home.packages = [
    (
      let
        menuConfig = pkgs.writeText "fuzzel-powermenu.ini" ''
          [main]
          font=AtkynsonMono Nerd Font Mono:size=22
          hide-prompt=yes
          # without this, focus_follows_mouse makes the menu vanish the moment the pointer leaves it
          exit-on-keyboard-focus-loss=no
          lines=4
          width=16
          horizontal-pad=60
          vertical-pad=30
          inner-pad=14
          line-height=68

          [border]
          width=3
          radius=6

          [key-bindings]
          # testing j/k navigation here, scoped to this config so the launcher keeps them as plain input
          prev=Up k
          next=Down j
          # letters do nothing here, a stray key can't filter the hidden list
          cursor-home=a b c d e f g h i l m n o p q r s t u v w x y z space comma period slash semicolon apostrophe bracketleft bracketright backslash

          [colors]
          background=2a1c0ef2
          text=9a8f80ff
          match=d4783aff
          selection=6a5535ff
          selection-text=ffffffff
          selection-match=d4783aff
          border=6a5535ff
        '';
      in
      pkgs.writeShellApplication {
        name = "powermenu";
        runtimeInputs = with pkgs; [ fuzzel systemd ];
        text = ''
          choice=$(printf '%s\n' \
            "󰌾    Lock" \
            "󰒲    Suspend" \
            "󰜉    Reboot" \
            "󰐥    Shutdown" \
            | fuzzel --dmenu --config=${menuConfig}) || exit 0
          case "$choice" in
            *Lock*)     loginctl lock-session ;;
            *Suspend*)  systemctl suspend ;;
            *Reboot*)   systemctl reboot ;;
            *Shutdown*) systemctl poweroff ;;
          esac
        '';
      }
    )
  ];

  # power menu in the fuzzel app list, same script as the waybar button and Mod+Shift+e
  xdg.desktopEntries.power-menu = {
    name = "Power";
    exec = "powermenu";
    terminal = false;
    icon = "system-shutdown";
    categories = [ "System" ];
  };
}
