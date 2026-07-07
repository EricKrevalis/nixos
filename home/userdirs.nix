{ ... }:

{
  # createDirectories makes these at activation, ~/Pictures included for the wallpaper and screenshots
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;     # no desktop icon renderer on sway
    publicShare = null; # nothing serves it without a share daemon
    download = "$HOME/Downloads";
    documents = "$HOME/Documents";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    templates = "$HOME/Templates"; # thunar's create-document menu reads this
  };

  # usb/drive automount, read by thunar-volman
  xfconf.settings.thunar-volman = {
    "automount-drives/enabled" = true;
    "automount-media/enabled" = true;
  };
}
