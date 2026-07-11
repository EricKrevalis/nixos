{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # both branches are the same 6.19.8 kernel right now, staying on longterm
  hardware.microsoft-surface.kernelVersion = "longterm";

  # touch, pen and performance profile switching are already on by default, nothing to set here

  # platform_profile has no udev device, permissions get widened directly for user access
  systemd.tmpfiles.rules = [
    "z /sys/firmware/acpi/platform_profile 0664 root users - -"
  ];

  # TLP not enabled: known to cause problems on Surface hardware unless hand-tuned

  system.stateVersion = "26.05";
}
