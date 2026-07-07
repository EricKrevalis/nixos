{ pkgs, ... }:

{
  # one base16 palette for every themed app, seeded from the hand-tuned forest colors
  # targets auto-enable per installed app, the opt-outs sit next to the app they exempt
  stylix = {
    enable = true;
    polarity = "dark";
    # no image set, swaybg keeps owning the wallpaper
    base16Scheme = {
      base00 = "16120b"; # background, warm near black, PROVISIONAL
      base01 = "2a1c0e"; # lighter background
      base02 = "3a2210"; # selection, dark brown
      base03 = "6a5535"; # comments, brown
      base04 = "9a8f80"; # dim foreground
      base05 = "d8cfc0"; # foreground, warm off white, PROVISIONAL
      base06 = "e8e2d5"; # light foreground, PROVISIONAL
      base07 = "f5f1e8"; # lightest, PROVISIONAL
      base08 = "cc3333"; # red
      base09 = "d4783a"; # orange accent
      base0A = "c9a554"; # yellow, PROVISIONAL
      base0B = "6b8a62"; # green
      base0C = "7d9470"; # cyan slot, sage
      base0D = "8a9bab"; # blue slot, grey blue, palette has no blue, PROVISIONAL
      base0E = "aa6a42"; # magenta slot, brown orange
      base0F = "bc4e20"; # burnt orange
    };
    # pin the fonts already in use, stylix would default to dejavu
    fonts = {
      # mono on every role, atkinson mono reads easiest, sans and serif get it too
      sansSerif = { package = pkgs.atkinson-hyperlegible-mono; name = "Atkinson Hyperlegible Mono"; };
      serif     = { package = pkgs.atkinson-hyperlegible-mono; name = "Atkinson Hyperlegible Mono"; };
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
