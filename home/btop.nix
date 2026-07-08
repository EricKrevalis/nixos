{
  # package stays system-side, the nvidia overlay wraps it there for libnvidia-ml
  # config only, enabled for stylix's btop target
  programs.btop = {
    enable = true;
    package = null;
  };
}
