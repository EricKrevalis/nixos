{ pkgs, ... }:

{
  # one base16 palette for every themed app, trying pkgs.base16-schemes bundles
  # targets auto-enable per installed app, the opt-outs sit next to the app they exempt
  # hand-tuned forest hexes are the pre-bundle snapshot in docs/colors.md
  stylix = {
    enable = true;
    polarity = "dark";
    # no image set, swaybg keeps owning the wallpaper
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
    # full stock palette, no overrides, including its base0D teal as the system accent
    # pin the fonts already in use, stylix would default to dejavu
    fonts = {
      # sans and serif get next, its proportional spacing sits better in gtk ui, mono stays for code
      sansSerif = { package = pkgs.atkinson-hyperlegible-next; name = "Atkinson Hyperlegible Next"; };
      serif     = { package = pkgs.atkinson-hyperlegible-next; name = "Atkinson Hyperlegible Next"; };
      monospace = { package = pkgs.atkinson-hyperlegible-mono; name = "Atkinson Hyperlegible Mono"; };
      emoji     = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
      # all four roles pinned above, nothing rides a hidden default
      # applications drives the gtk ui font
      sizes = {
        applications = 10; # gtk ui, file dialogs, firefox chrome
        desktop      = 10; # titlebars, status bars
        popups       = 10; # notifications, launcher
        terminal     = 12; # foot, editors
      };
    };
  };
}
