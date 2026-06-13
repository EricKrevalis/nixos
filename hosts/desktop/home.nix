{ ... }:

{
  # three 1920x1080 monitors, left -> right. two are the same model (Zowie XL),
  # so they're pinned by connector. serials kept in case connectors ever shuffle:
  #   HDMI-A-1 = Zowie XL    (sn GAG02576SL0)    left,   60Hz
  #   DP-1     = Zowie XL    (sn EBM2M00765SL0)  middle, 240Hz (main)
  #   DP-2     = BenQ RL2455 (sn S4D05178SL0)    right,  60Hz
  wayland.windowManager.sway.config = {
    output = {
      "HDMI-A-1" = { mode = "1920x1080@60Hz"; position = "0,0"; };
      "DP-1" = { mode = "1920x1080@240Hz"; position = "1920,0"; };
      "DP-2" = { mode = "1920x1080@60Hz"; position = "3840,0"; };
    };

    # anchor workspaces so each monitor lights up at login and the main (DP-1)
    # holds the primary ones. easy to re-tune later.
    workspaceOutputAssign = [
      { workspace = "1"; output = "DP-1"; }
      { workspace = "2"; output = "DP-1"; }
      { workspace = "3"; output = "DP-1"; }
      { workspace = "4"; output = "HDMI-A-1"; }
      { workspace = "5"; output = "HDMI-A-1"; }
      { workspace = "6"; output = "DP-2"; }
      { workspace = "7"; output = "DP-2"; }
    ];
  };

  # WirePlumber drop-ins for this machine's specific audio devices
  xdg.configFile."wireplumber/wireplumber.conf.d".source = ../../configs/wireplumber;
}
