{ config, lib, ... }:

# proprietary nvidia driver for wayland + gaming, active when host.nvidia = true.
# open = true uses the open kernel modules (Turing/Ampere or newer), still the proprietary
# userspace driver, not nouveau. if the display flickers or suspend breaks, set open = false
# and rebuild.
lib.mkIf config.host.nvidia {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true; # required for wayland, enables explicit sync path
    open = true; # see header for the closed-module fallback
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable; # stable branch
    powerManagement.enable = false; # enable if suspend/resume corrupts the display
  };
}
