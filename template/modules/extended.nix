{ config, lib, pkgs, ... }:

# feature complete desktop on top of basic, enabled by host.extended
lib.mkIf config.host.extended {
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-volman thunar-archive-plugin ];
  };
  services.gvfs.enable = true;    # trash, MTP devices, network locations
  services.tumbler.enable = true; # thumbnail generation
}
