{ settings, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # TESTING: linux-surface's default kernel branch, retest against "stable" after the first real boot.
  hardware.microsoft-surface.kernelVersion = "longterm";

  # disabled for the first real install, see docs/todo.md for why and what to retry
  # hardware.microsoft-surface.ipts.enable = true; # touch + pen digitizer
  # hardware.microsoft-surface.surface-control.enable = true; # performance mode control
  # its polkit rule only grants access to this group, membership is never automatic
  # users.users.${settings.username}.extraGroups = [ "surface-control" ];

  # TLP not enabled: known to cause problems on Surface hardware unless hand-tuned

  system.stateVersion = "26.05";
}
