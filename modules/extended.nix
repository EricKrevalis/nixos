{ config, lib, pkgs, ... }:

# feature complete desktop for normal use, on top of basic
# enabled by host.extended, empty until the stack lands
lib.mkIf config.host.extended {
  environment.systemPackages = with pkgs; [
  ];
}
