{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # laptop-only sway extras (lock, idle, backlight), these merge with basic.nix's empty list
  programs.sway.extraPackages = with pkgs; [ swaylock swayidle brightnessctl ];

  system.stateVersion = "26.05";
}
