{ settings, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # backlight control, surface only. swaylock/swayidle already come from the shared home modules.
  programs.sway.extraPackages = with pkgs; [ brightnessctl ];

  # TESTING: linux-surface's default kernel branch, retest against "stable" after the first real boot.
  hardware.microsoft-surface.kernelVersion = "longterm";
  hardware.microsoft-surface.ipts.enable = true; # touch + pen digitizer
  hardware.microsoft-surface.surface-control.enable = true; # performance mode control
  # its polkit rule only grants access to this group, membership is never automatic
  users.users.${settings.username}.extraGroups = [ "surface-control" ];

  # TLP not enabled: known to cause problems on Surface hardware unless hand-tuned

  system.stateVersion = "26.05";
}
