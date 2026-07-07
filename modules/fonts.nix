{ pkgs, ... }:

{
  # explicit font set
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      noto-fonts                # ui sans and serif, broad latin and ~900 script faces, no cjk
      noto-fonts-cjk-sans       # chinese/japanese/korean sans, base noto ships none
      noto-fonts-cjk-serif      # cjk serif counterpart
      noto-fonts-color-emoji    # emoji
      nerd-fonts.atkynson-mono  # mono, atkinson hyperlegible, terminal and monospace role
      # nerd-fonts.caskaydia-cove # alt mono, patched cascadia code
      # nerd-fonts.sauce-code-pro # alt mono, source code pro
    ];
    # point the generic family aliases at the font set, otherwise nixos falls back to dejavu
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" ];
      serif     = [ "Noto Serif" ];
      monospace = [ "AtkynsonMono Nerd Font Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };
}
