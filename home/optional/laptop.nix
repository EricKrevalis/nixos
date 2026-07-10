{ settings, lib, ... }:

# laptop-specific keybinds, enabled by the laptop toggle in flake.nix
lib.mkIf settings.laptop {
  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
    "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
  };
}
