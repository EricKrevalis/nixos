{ pkgs, ... }:

{
  # explicit font set
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      atkinson-hyperlegible-next   # ui sans and serif role, the everywhere font
      atkinson-hyperlegible-mono   # monospace role, official mono, no baked-in icons
      nerd-fonts.symbols-only      # nerd icons only, the fallback for glyphs mono lacks
      noto-fonts                   # latin fallback under atkinson, ~900 script faces, no cjk
      noto-fonts-cjk-sans          # chinese/japanese/korean sans, base noto ships none
      noto-fonts-cjk-serif         # cjk serif counterpart
      noto-fonts-color-emoji       # emoji
    ];
    # point the generic family aliases at the font set, atkinson first then noto for missing glyphs
    fontconfig.defaultFonts = {
      sansSerif = [ "Atkinson Hyperlegible Next" "Noto Sans" ];
      serif     = [ "Atkinson Hyperlegible Next" "Noto Serif" ];
      monospace = [ "Atkinson Hyperlegible Mono" "Symbols Nerd Font Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
    # the aliases above only reach apps asking for "monospace", ones naming a concrete family (foot, stylix) skip them
    # append symbols to every request, picked only for nerd icons the named font lacks, else those fall to dejavu
    # strong binding, a weak one loses the icon slot back to dejavu
    fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <match target="pattern">
          <edit name="family" mode="append" binding="strong">
            <string>Symbols Nerd Font Mono</string>
          </edit>
        </match>
      </fontconfig>
    '';
  };
}
