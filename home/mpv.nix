{ ... }:

{
  programs.mpv = {
    enable = true;
    config.hwdec = "auto-safe"; # host gpu decoder when safe (nvdec here), else software
  };
}
