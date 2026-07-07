{ lib, pkgs, ... }:

{
  # screen locker. dark green fallback, stylix recolors it when enabled.
  programs.swaylock = {
    enable = true;
    settings = {
      color = lib.mkDefault "0f2910"; # dark green background while locked
      indicator-radius = 90;
      indicator-thickness = 8;
    };
  };

  # lock the screen before any suspend and on loginctl lock-session (the power menu's lock action).
  # no idle timeout, this desktop only locks on demand or before sleep.
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${lib.getExe pkgs.swaylock} -f";
      lock         = "${lib.getExe pkgs.swaylock} -f";
    };
  };
}
