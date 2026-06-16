{ settings, lib, ... }:

# home-side gaming tooling, gated like core/modules/specialized/gaming.nix.
lib.mkIf settings.gaming {
  # enable installs mangohud and manages the conf, so the package isn't in systemPackages
  programs.mangohud = {
    enable = true;
    settings = {
      fps = true;
      frametime = true;
      frame_timing = true; # the stutter graph
      gpu_stats = true;
      gpu_temp = true;
      cpu_stats = true;
      cpu_temp = true;
      vram = true;
      ram = true;
      gamemode = true; # confirms gamemode actually engaged

      position = "top-left";
      font_size = 14;
      alpha = 0.65;
      background_alpha = 0.35;
      toggle_hud = "Shift_R+F12";
    };
  };
}
