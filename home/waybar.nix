{ config, settings, lib, ... }:

{
  # per-host workspace dots, filled by hosts/<host>/home.nix next to its monitor layout
  options.host.persistentWorkspaces = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = { };
    description = "waybar persistent-workspaces map, workspace number to outputs";
  };

  config = {
    xdg.configFile."waybar/config.jsonc".text = builtins.toJSON ({
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
      "modules-right"  = [ "group/systray" "group/connectivity" ] ++ lib.optionals settings.laptop [ "group/laptop" ];

      "group/systray" = {
        orientation = "horizontal";
        modules     = [ "tray" ];
      };

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
        # tray's own tooltip popup steals hover focus and drops the pill's :hover background
        tooltip             = false;
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
        "format-wifi"        = "󰤨";
        "format-ethernet"    = "󰈀";
        "format-linked"      = "󰈀"; # raw iface name shows without this
        "format-disconnected" = "󰤭";
        tooltip    = false;
        "on-click" = "foot --app-id=popup-terminal nmtui";
      };

      clock = {
        format = "{:%Y-%m-%d  %H:%M}";
      };
    } // lib.optionalAttrs settings.laptop {
      "group/laptop" = {
        orientation = "horizontal";
        modules     = [ "backlight" "battery" ];
      };

      backlight = {
        format         = "{percent}% {icon}";
        "format-icons" = [ "󰃞" "󰃟" "󰃠" ];
        tooltip        = false;
      };

      # click opens the profile picker
      battery = {
        states = { warning = 20; critical = 10; };
        format          = "{capacity}% {icon}";
        "format-charging" = "{capacity}% 󰂄";
        "format-icons"  = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
        tooltip         = false;
        "on-click"      = "laptop-menu";
      };
    });

    # xdg.configFile writes style.css directly, stylix's waybar target has no programs.waybar module to hook into
    # css layout is hand-tuned, colors interpolated from config.lib.stylix.colors below
    xdg.configFile."waybar/style.css".text =
      let
        c = config.lib.stylix.colors;
        rgba = slot: alpha: "rgba(${c."${slot}-rgb-r"}, ${c."${slot}-rgb-g"}, ${c."${slot}-rgb-b"}, ${alpha})";
      in
      ''
        * {
            font-family: "Atkinson Hyperlegible Mono", "Symbols Nerd Font Mono";
            font-size: 9px;
            font-weight: 700;
            border: none;
            border-radius: 0;
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: #${c.base0F};
        }

        /* shared pill base */
        #launcher,
        #clock,
        #workspaces,
        #systray,
        #connectivity,
        #laptop {
            background: #${c.base01};
            border: 1px solid #${c.base0F};
            border-top: none;
            border-radius: 0 0 6px 6px;
            padding: 0 4px;
            margin: 0px 6px 0;
        }

        /* launcher group pill */
        #launcher {
            padding: 0 2px;
        }

        #custom-power,
        #custom-files,
        #custom-search,
        #custom-terminal {
            padding: 0 6px;
            color: #${c.base0F};
        }

        /* clock pill */
        #clock {
            color: #${c.base0A};
            padding: 0 6px;
        }

        /* workspace dots */
        #workspaces {
            padding: 0 2px;
        }

        #workspaces button {
            padding: 0 2px;
            color: #${c.base0A};
            background: transparent;
            font-size: 9px;
        }

        #workspaces button.focused {
            color: #${c.base0F};
            font-size: 9px;
            background: transparent;
        }

        #workspaces button.persistent.empty {
            color: #${c.base03};
            font-size: 9px;
        }

        #workspaces button:hover {
            border-radius: 0 0 4px 4px;
            color: #${c.base0C};
        }

        #workspaces button.persistent.empty:hover {
            color: #${c.base0C};
        }

        /* systray group pill */
        #systray {
            padding: 0 2px;
            margin-right: 4px;
        }

        #tray {
            padding: 0 6px;
        }

        /* connectivity group pill */
        #connectivity {
            padding: 0 2px;
            margin-left: 4px;
        }

        #pulseaudio,
        #bluetooth,
        #network {
            padding: 0 6px;
            color: #${c.base0F};
        }

        #pulseaudio.muted {
            color: #${c.base04};
        }

        #bluetooth.disconnected,
        #network.disconnected {
            color: #${c.base04};
        }

        /* cable in, no internet, same muted color as disconnected/muted states */
        #network.linked {
            color: #${c.base04};
        }

        /* laptop group pill */
        #laptop {
            padding: 0 2px;
            margin-left: 4px;
        }

        #backlight,
        #battery {
            padding: 0 6px;
            color: #${c.base0F};
        }

        #battery.warning {
            color: #${c.base0A};
        }

        #battery.critical {
            color: #${c.base08};
        }

        /* hover bg, all clickable pills + workspace dots, last for specificity over .focused */
        #custom-power:hover,
        #custom-files:hover,
        #custom-search:hover,
        #custom-terminal:hover,
        #pulseaudio:hover,
        #bluetooth:hover,
        #network:hover,
        #backlight:hover,
        #battery:hover,
        #tray:hover,
        #workspaces button:hover {
            background: ${rgba "base0A" "0.2"};
        }
      '';
  };
}
