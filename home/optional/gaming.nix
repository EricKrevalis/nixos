{ settings, lib, config, ... }:

# home-side gaming tooling, enabled by the gaming toggle
lib.mkIf settings.gaming {
  # proton/xwayland windows tile by default, force them fullscreen. class is steam_app_<id>
  wayland.windowManager.sway.config.window.commands = [
    {
      criteria.class = "^steam_app_[0-9]+$";
      command = "fullscreen enable";
    }
  ];

  # the overlay below is tuned for low visibility, stylix's target would also force its own
  # alpha/background_alpha/font_size. colors pulled by hand instead, same role mapping the
  # target itself uses, alpha/font_size kept local.
  stylix.targets.mangohud.enable = false;

  # enable installs mangohud and manages the conf, so the package isn't in systemPackages
  programs.mangohud = {
    enable = true;
    settings =
      let c = config.lib.stylix.colors; in # mangohud's own conf format wants bare hex, no '#'
      {
        fps = true;
        frametime = true;
        frame_timing = false; # the stutter graph
        gpu_stats = true;
        gpu_temp = true;
        cpu_stats = true;
        cpu_temp = true;
        vram = true;
        ram = true;
        gamemode = false; # confirms gamemode actually engaged

        position = "top-left";
        font_size = 14;
        width = 150;
        alpha = 0.35;
        background_alpha = 0.25;
        fps_sampling_period = 500; # default, but changes CPU draw
        toggle_hud = "Shift_R+F12";

        text_color = c.base05;
        text_outline_color = c.base00;
        background_color = c.base00;
        gpu_color = c.base0B;
        cpu_color = c.base0D;
        vram_color = c.base0C;
        media_player_color = c.base05;
        engine_color = c.base0E;
        wine_color = c.base0E;
        frametime_color = c.base0B;
        battery_color = c.base04;
        io_color = c.base0A;
        gpu_load_color = "${c.base0B}, ${c.base0A}, ${c.base08}";
        cpu_load_color = "${c.base0B}, ${c.base0A}, ${c.base08}";
        fps_color = "${c.base0B}, ${c.base0A}, ${c.base08}";
      };
  };
}
