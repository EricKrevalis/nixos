{ config, settings, pkgs, lib, ... }:

let
  # matches the powermenu's colors/border
  colors = config.lib.stylix.colors;
  border = "${colors.base0F}ff";
in
# laptop-specific keybinds and tooling, enabled by the laptop toggle in flake.nix
lib.mkIf settings.laptop {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
    "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
  };

  # performance profile picker, opened from the waybar battery pill
  # own compact fuzzel config, sized for a short profile list
  home.packages = [
    (
      let
        menuConfig = pkgs.writeText "fuzzel-laptop-menu.ini" ''
          [main]
          font=Atkinson Hyperlegible Next:size=14, Symbols Nerd Font Mono:size=14
          prompt="performance: "
          lines=8
          minimal-lines=yes
          width=27
          # stops focus_follows_mouse from killing the menu the moment the pointer leaves it
          exit-on-keyboard-focus-loss=no
          horizontal-pad=74
          vertical-pad=32
          inner-pad=20
          line-height=28

          [border]
          width=3
          radius=6

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
        name = "laptop-menu";
        runtimeInputs = with pkgs; [ fuzzel surface-control ];
        text = ''
          current=$(surface profile get)
          choice=$(surface profile list | while read -r p; do
            if [ "$p" = "$current" ]; then printf '󰄲 %s\n' "$p"; else printf '󰄱 %s\n' "$p"; fi
          done | fuzzel --dmenu --config=${menuConfig}) || exit 0
          surface profile set "''${choice#* }"
        '';
      }
    )
  ];
}
