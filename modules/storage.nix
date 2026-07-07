{ pkgs, ... }:

{
  services.udisks2.enable = true; # drive mounting backend, needed for USB automount and udisksctl

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-volman thunar-archive-plugin ];
  };
  services.gvfs.enable = true;    # trash, MTP devices, network locations
  services.tumbler.enable = true; # thumbnail generation

  services.fwupd.enable = false; # enable to flash device firmware via lvfs then set false again, the flash persists on the device
}
