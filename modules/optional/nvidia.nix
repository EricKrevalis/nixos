{ settings, config, lib, ... }:

# proprietary nvidia driver for wayland and gaming, enabled by the nvidia toggle in flake.nix.
# open = true uses the open kernel modules (Turing/Ampere or newer), still proprietary userspace, not nouveau.
# flicker or broken suspend, set open = false and rebuild.
lib.mkIf settings.nvidia {
  # desktop.nix runs sessionPreExec right before launching sway and appends swayLaunchArgs to the command.
  # sway needs the gles2 renderer and --unsupported-gpu on nvidia, integrated gpus do not.
  # hardware cursors on, re-add WLR_NO_HARDWARE_CURSORS=1 here if a game hides the cursor.
  host.sessionPreExec = ''
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_RENDERER=gles2
  '';
  host.swayLaunchArgs = [ "--unsupported-gpu" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  # nixpkgs loads these only when services.xserver.enable is set, off on a wayland-only session.
  # without nvidia_drm there's no KMS, sway drops to the EFI framebuffer.
  boot.kernelModules = [ "nvidia_modeset" "nvidia_drm" ];

  # late-loading nvidia_drm sometimes loses the race with simpledrm for the framebuffer
  # (ENOMEM on insert, sway falls back to a fake 1024x768 output). load in initrd instead.
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];

  hardware.nvidia = {
    modesetting.enable = true; # required for wayland, enables explicit sync path
    open = true; # see header for the closed-module fallback
    nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.stable; # stable branch
    package = config.boot.kernelPackages.nvidiaPackages.latest; # 610, adds dmabuf mmap on discrete gpus, swap in to test the firefox flicker

    powerManagement.enable = true; # PROVISIONAL: saves/restores vram so suspend resumes clean, test resume under real load
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
