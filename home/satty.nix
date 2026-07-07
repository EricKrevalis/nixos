{ settings, ... }:

{
  xdg.configFile."satty/config.toml".text = ''
    [general]
    early-exit = true
    save-after-copy = true
    output-filename = "/home/${settings.username}/Pictures/screenshot-%Y-%m-%d_%H:%M:%S.png"
    copy-command = "wl-copy"
    initial-tool = "arrow"
    annotation-size-factor = 2
    corner-roundness = 1
    '';
}
