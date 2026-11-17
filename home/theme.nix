{ pkgs, ... }:

{
  home.pointerCursor = {
    enable  = true; # the settings below don't turn this on by themselves
    package = pkgs.bibata-cursors;
    name    = "Bibata-Modern-Classic";
    size    = 20;
    sway.enable = true; # writes seat "*" { xcursor_theme = "..."; } into the sway config
  };

  # enabling gtk hands home-manager the settings.ini, so every pref has to be set here.
  # prefer-dark keeps thunar and other gtk apps dark, primary-paste off turns off middle-click paste
  gtk = {
    enable = true;
    # papirus-dark icon theme, light-on-dark for the dark desktop
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-enable-primary-paste = false;
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-enable-primary-paste = false;
      gtk-application-prefer-dark-theme = true;
    };
  };
}
