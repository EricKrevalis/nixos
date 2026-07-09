{ config, pkgs, lib, ... }:

let
  # same role mapping as stylix's own fuzzel target, keeps the powermenu's separate ini in sync
  colors = config.lib.stylix.colors;
  # border color, used by both the main launcher and the powermenu ini below
  border = "${colors.base0F}ff";
in
{
  programs.fuzzel = {
    enable = true;
    package = null; # fuzzel is installed system-wide, home-manager only writes the config
    # fuzzel runs Terminal=true apps in xterm by default, xterm isn't installed here.
    # foot takes the command as trailing args, so no -e, just "foot".
    settings.main = {
      terminal = "foot";
      # unset falls back to the literal theme named "default" (the cursor theme), not the desktop icon theme
      "icon-theme" = "Papirus-Dark";
      # stylix drives the popup font size, forced here to grow only the launcher
      font     = lib.mkForce "Atkinson Hyperlegible Next:size=14";
      lines    = 16;
      width    = 30; # keep this close to actual entry length, extra chars become dead space on the right
      # stops focus_follows_mouse from killing the launcher the moment the pointer leaves it
      "exit-on-keyboard-focus-loss" = false;
      "horizontal-pad" = 80;
      "vertical-pad"   = 24;
      "inner-pad"      = 16;
      "letter-spacing" = 2;
      "line-height"    = 24; # taller rows per entry, on top of the outer padding
    };
    settings.border = {
      width  = 3;
      radius = 6;
    };
    # rest of the colors left to stylix's fuzzel target, border alone pulled off it
    settings.colors.border = lib.mkForce border;
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
          font=Atkinson Hyperlegible Mono:size=22, Symbols Nerd Font Mono:size=22
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
          # testing j/k navigation here, scoped to this config, the launcher keeps them as plain input
          prev=Up k
          next=Down j
          # q cancels the menu alongside the default Escape and Ctrl+c
          cancel=Escape Control+c q
          # letters do nothing here, a stray key can't filter the hidden list
          cursor-home=a b c d e f g h i l m n o p r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 minus equal space comma period slash semicolon apostrophe bracketleft bracketright backslash

          [colors]
          background=${colors.base00}ff
          text=${colors.base05}ff
          match=${colors.base0A}ff
          selection=${colors.base02}ff
          selection-text=${colors.base05}ff
          selection-match=${colors.base0A}ff
          border=${border}
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
