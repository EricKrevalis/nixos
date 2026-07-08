{ config, lib, ... }:

{
  # per-host workspace dots, filled by hosts/<host>/home.nix next to its monitor layout
  options.host.persistentWorkspaces = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = { };
    description = "waybar persistent-workspaces map, workspace number to outputs";
  };

  config = {
    xdg.configFile."waybar/config.jsonc".text = builtins.toJSON {
      layer    = "top";
      position = "top";
      height   = 14;
      "margin-top"   = -2;
      "margin-left"  = 280;
      "margin-right" = 280;
      exclusive = false;
      spacing   = 0;

      "modules-left"   = [ "group/launcher" "clock" ];
      "modules-center" = [ "sway/workspaces" ];
      "modules-right"  = [ "tray" "group/connectivity" ];

      "group/launcher" = {
        orientation = "horizontal";
        modules     = [ "custom/power" "custom/files" "custom/search" "custom/terminal" ];
      };

      "custom/power" = {
        format     = "󰐥";
        tooltip    = false;
        "on-click" = "powermenu";
      };

      "custom/files" = {
        format     = "󰉋";
        tooltip    = false;
        "on-click" = "thunar";
      };

      "custom/search" = {
        format     = "󰍉";
        tooltip    = false;
        "on-click" = "fuzzel";
      };

      "custom/terminal" = {
        format     = "󰆍";
        tooltip    = false;
        "on-click" = "foot";
      };

      "sway/workspaces" = {
        format             = "●";
        "disable-scroll"   = true;
        "persistent-workspaces" = config.host.persistentWorkspaces;
      };

      "group/connectivity" = {
        orientation = "horizontal";
        modules     = [ "pulseaudio" "bluetooth" "network" ];
      };

      tray = {
        "icon-size"         = 10;
        spacing             = 8;
        "reverse-direction" = true;
      };

      pulseaudio = {
        format         = "{volume}% {icon}";
        "format-muted" = "mute 󰝟";
        "format-icons" = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        "on-click"     = "foot --app-id=popup-terminal wiremix";
      };

      bluetooth = {
        format                     = "󰂯";
        "format-connected"         = "󰂱 {device_alias}";
        "format-connected-battery" = "󰂱 {device_alias} {device_battery_percentage}%";
        tooltip    = false;
        "on-click" = "foot --app-id=popup-terminal bluetui";
      };

      network = {
        interval             = 0;
        "format-wifi"        = "󰤨 {essid}";
        "format-ethernet"    = "󰈀";
        "format-disconnected" = "󰤭";
        tooltip    = false;
        "on-click" = "foot --app-id=popup-terminal nmtui";
      };

      clock = {
        format = "{:%Y-%m-%d  %H:%M}";
      };
    };

    # the style.css is hand-tuned, stylix stays out of waybar
    stylix.targets.waybar.enable = false;
    xdg.configFile."waybar/style.css".source = ../configs/waybar/style.css;
  };
}
