{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # longterm is the lts line, stable follows the newest kernel
  hardware.microsoft-surface.kernelVersion = "longterm";

  # touch, pen and performance profile switching are already on by default, nothing to set here

  # platform_profile has no udev device, permissions get widened directly for user access
  systemd.tmpfiles.rules = [
    "z /sys/firmware/acpi/platform_profile 0664 root users - -"
  ];

  # TLP not enabled: known to cause problems on Surface hardware unless hand-tuned

  system.stateVersion = "26.05";
}
