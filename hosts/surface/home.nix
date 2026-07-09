{ ... }:

{
  wayland.windowManager.sway.extraConfig = ''
    workspace 1 output eDP-1
    workspace 2 output eDP-1
    workspace 3 output eDP-1
    workspace 4 output eDP-1
    workspace 5 output eDP-1
    workspace number 1
  '';

  # waybar workspace dots, mirrors the assignment above
  host.persistentWorkspaces = {
    "1" = [ "eDP-1" ]; "2" = [ "eDP-1" ]; "3" = [ "eDP-1" ]; "4" = [ "eDP-1" ]; "5" = [ "eDP-1" ];
  };
}
