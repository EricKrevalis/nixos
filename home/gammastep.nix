{ ... }:

{
  # night light. fixed times, no geoclue daemon or location in the repo
  services.gammastep = {
    enable = true;
    tray = true; # gammastep-indicator, a tray icon on the same schedule
    provider = "manual";
    dawnTime = "6:00-8:00";
    duskTime = "19:00-21:00";
    temperature = {
      day = 6500;
      night = 1900;
    };
  };
}
