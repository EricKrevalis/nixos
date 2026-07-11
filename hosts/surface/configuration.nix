{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # both branches are the same 6.19.8 kernel right now, staying on longterm
  hardware.microsoft-surface.kernelVersion = "longterm";

  # touch, pen and performance profile switching are already on by default, nothing to set here

  # TLP not enabled: known to cause problems on Surface hardware unless hand-tuned

  system.stateVersion = "26.05";
}
