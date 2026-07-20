{ pkgs, ... }:

let
  # $DBUS must land inside the same quoted exec argument as the script path:
  # zathura's config parser only keeps one token as the exec argument, so a
  # bare trailing $DBUS gets silently dropped before substitution ever runs.
  toggleCopyMode = pkgs.writeShellScript "zathura-toggle-copy-mode" ''
    dbus="$1"
    state="/tmp/zathura-copy-mode-''${dbus}"
    if [ -e "$state" ]; then
      rm -f "$state"
      busctl --user call "$dbus" /org/pwmt/zathura org.pwmt.zathura ExecuteCommand s "set selection-clipboard false"
      notify-send -t 1200 "zathura" "copy mode off"
    else
      touch "$state"
      busctl --user call "$dbus" /org/pwmt/zathura org.pwmt.zathura ExecuteCommand s "set selection-clipboard clipboard"
      notify-send -t 1200 "zathura" "copy mode on"
    fi
  '';
in
{
  programs.zathura = {
    enable = true; # mupdf backend bundled, no extra plugin
    # off by default, not primary either; Y toggles clipboard copy on/off
    options.selection-clipboard = "false";
    options.selection-notification = false;
    # nvim-style paging: h/l and the arrows flip pages, j/k keep their default scroll
    mappings = {
      h = "navigate previous";
      l = "navigate next";
      "<Left>" = "navigate previous";
      "<Right>" = "navigate next";
      Y = ''exec "${toggleCopyMode} $DBUS"'';
    };
  };
}
