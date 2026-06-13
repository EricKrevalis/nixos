{ lib, ... }:

# typed schema for the per-host toggles set in flake.nix common. one documented place for
# a forker to see the knobs, and a wrong value is a build error. non-nvidia gpus need
# nothing here, they run on the default mesa stack from basic.nix.
{
  options.host.nvidia =
    lib.mkEnableOption "the proprietary nvidia gpu stack (driver plus wlroots quirks)";
  # software tiers stack basic -> extended -> specialized
  options.host.extended =
    lib.mkEnableOption "the feature complete desktop for normal use";
  options.host.specialized =
    lib.mkEnableOption "the dev and gaming layer on top of extended";
}
