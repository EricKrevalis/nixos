{ config, lib, ... }:

# proprietary nvidia driver for wayland and gaming, active when host.nvidia = true.
# open = true uses the open kernel modules (Turing/Ampere or newer), still proprietary userspace, not nouveau.
# flicker or broken suspend, set open = false and rebuild.
lib.mkIf config.host.nvidia {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true; # required for wayland, enables explicit sync path
    open = true; # see header for the closed-module fallback
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable; # stable branch
    powerManagement.enable = false; # enable if suspend/resume corrupts the display
  };

  # btop finds the gpu only via libnvidia-ml, kept off the linker path on nixos
  nixpkgs.overlays = [
    (final: prev: {
      btop = prev.symlinkJoin {
        name = "btop";
        paths = [ prev.btop ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/btop --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
        '';
      };
    })
  ];
}
