{ lib, ... }:

# declares and types the host.* toggles, nothing to change here.
# set the values in flake.nix common, a wrong value is a build error.
{
  # software layers stack base -> polish -> specialized, base is always on
  options.host.polish =
    lib.mkEnableOption "the polished, feature complete desktop for normal use";
  options.host.dev =
    lib.mkEnableOption "dev tools layer on top of polish";
  options.host.gaming =
    lib.mkEnableOption "gaming layer on top of polish";
  options.host.nvidia =
    lib.mkEnableOption "the proprietary nvidia gpu stack (driver plus wlroots quirks)";
  options.host.arkenfox =
    lib.mkEnableOption "arkenfox-hardened firefox, requires uBlock script handling knowledge and exception management";

  # internal session-launch hooks a hardware layer fills, not user-facing toggles.
  # base stays gpu-agnostic, the nvidia layer supplies its own launch env and sway flags.
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
}
