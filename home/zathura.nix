{ ... }:

{
  programs.zathura = {
    enable = true; # mupdf backend bundled, no extra plugin
    # never copy selected text anywhere, not primary, not clipboard (default is primary)
    options.selection-clipboard = "false";
    options.selection-notification = false;
    # nvim-style paging: h/l and the arrows flip pages, j/k keep their default scroll
    mappings = {
      h = "navigate previous";
      l = "navigate next";
      "<Left>" = "navigate previous";
      "<Right>" = "navigate next";
    };
  };
}
