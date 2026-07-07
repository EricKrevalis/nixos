{ settings, config, lib, pkgs, ... }:

{
  # session launch hooks, inter-module wiring rather than user-facing switches.
  # the launch below stays gpu-agnostic, optional/nvidia.nix fills these.
  options.host.sessionPreExec = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "shell run in the login shell right before sway launches";
  };
  options.host.swayLaunchArgs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "extra flags appended to the sway launch command";
  };

  config = {
    # autologin tty1 then exec sway, no display manager.
    # launch is system level via loginShellInit, independent of the login shell.
    programs.sway = {
      enable = true;
      package = pkgs.swayfx;
      # [] keeps sway's default bundle out (pulseaudio, wmenu, foot, swaylock, swayidle, grim).
      # the ones kept are installed via their own modules so they carry config, wmenu is dropped for fuzzel.
      extraPackages = [ ];
    };
    # sway's graphical-desktop base turns on speech-dispatcher, it drags in 700+ MiB of tts voices
    services.speechd.enable = false;
    services.getty.autologinUser = settings.username;
    environment.loginShellInit = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        ${config.host.sessionPreExec}
        # electron/chromium apps render on wayland instead of xwayland
        export NIXOS_OZONE_WL=1
        exec sway ${toString config.host.swayLaunchArgs}
      fi
    '';

    # accelerated GL for wayland/sway, every gpu needs this
    hardware.graphics.enable = true;

    # graphical polkit agent for gui apps needing elevation, cli falls back to pkttyagent
    security.soteria.enable = true;

    # lets swaylock verify the password and unlock, without it the session is a one-way trap
    security.pam.services.swaylock = { };

    # two local patches to xdg-desktop-portal-wlr, both fix discord screenshare freezing.
    # destroy-stale-frame: portal reused a frame without freeing the old one, sway killed the session. upstream PR #380.
    # more-buffers: a pipewire pool of 2 starved the portal and froze the stream, bumped to 6, clear at 1080p60.
    # if a portal release fixes either the patch stops applying and the build fails, drop that file.
    nixpkgs.overlays = [
      (final: prev: {
        xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./patches/xdpw-destroy-stale-frame.patch
            ./patches/xdpw-more-buffers.patch
          ];
        });
      })
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      # wlr handles screen capture, gtk covers everything else (file picker, inhibit, settings)
      config.sway = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast"  = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot"  = [ "wlr" ];
      };
      # slurp draws a crosshair, click a monitor to pick it
      wlr.settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
      };
    };
  };
}
