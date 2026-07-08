{ pkgs, ... }:

{
  # y opens yazi, quitting cds the shell to wherever it landed
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # gw jumps straight to the work drive, alongside the stock gh/gc/gd goto binds
    keymap.mgr.prepend_keymap = [
      { on = [ "g" "w" ]; run = "cd /run/media/eric/work"; desc = "cd to the work drive"; }
    ];
  };

  # desktop Exec can't hold quotes or semicolons, this script runs the foot/zsh/y chain instead
  home.packages = [
    (pkgs.writeShellApplication {
      name = "yazi-term";
      runtimeInputs = [ pkgs.foot ];
      text = ''foot zsh -ic 'y; exec zsh' '';
    })
  ];

  # packaged yazi.desktop runs the raw binary with no cd-on-quit, this entry runs the script instead
  xdg.desktopEntries.yazi = {
    name = "Yazi File Manager"; # fuzzel default match fields are name and filename, not genericName
    icon = "system-file-manager"; # yazi ships no icon of its own, Papirus has none for it either
    exec = "yazi-term";
    terminal = false;
    categories = [ "System" "FileTools" "FileManager" ];
  };
}
