{ settings, pkgs, lib, ... }:

# laptop-specific keybinds and tooling, enabled by the laptop toggle in flake.nix
lib.mkIf settings.laptop {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
    "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
  };

  # performance profile picker, opened from the waybar battery pill
  home.packages = [
    (pkgs.writeShellApplication {
      name = "laptop-menu";
      runtimeInputs = with pkgs; [ fuzzel surface-control ];
      text = ''
        current=$(surface profile get)
        choice=$(surface profile list | while read -r p; do
          if [ "$p" = "$current" ]; then printf '* %s\n' "$p"; else printf '- %s\n' "$p"; fi
        done | fuzzel --dmenu --prompt="performance: ") || exit 0
        surface profile set "''${choice#* }"
      '';
    })
  ];
}
