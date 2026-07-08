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
            font-size: 10px;
            font-weight: 700;
            border: none;
            border-radius: 0;
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: #${c.base09};
        }

        /* shared pill base */
        #launcher,
        #clock,
        #workspaces,
        #tray,
        #connectivity {
            background: ${rgba "base01" "0.8"};
            border: 1px solid #${c.base0C};
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
            font-size: 9px;
            color: #${c.base09};
        }

        /* clock pill */
        #clock {
            color: #${c.base09};
            padding: 0 6px;
        }

        /* workspace dots */
        #workspaces {
            padding: 0 2px;
        }

        #workspaces button {
            padding: 0 2px;
            color: #${c.base06};
            background: transparent;
            font-size: 10px;
        }

        #workspaces button.focused {
            color: #${c.base09};
            font-size: 10px;
            background: transparent;
        }

        #workspaces button.persistent {
            color: #${c.base0B};
            font-size: 10px;
        }

        #workspaces button:hover {
            background: ${rgba "base0C" "0.35"};
            border-radius: 6px;
            color: #${c.base0A};
        }

        /* tray pill */
        #tray {
            padding: 0 6px;
            margin-right: 4px;
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
            color: #${c.base09};
        }

        #pulseaudio.muted {
            color: #${c.base04};
        }

        #bluetooth.disconnected,
        #network.disconnected {
            color: #${c.base04};
        }
      '';
  };
}
