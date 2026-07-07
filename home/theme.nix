{ pkgs, ... }:
let
  # papirus-dark reuses the light computer.svg; greys lifted so it shows on the dark desktop:
  #   body #333333->#585858  edge #595959->#6b6b6b  screen #8e8e8e->#999999
  iconTheme = "Papirus-Dark-eric";
  computerSvg = pkgs.writeText "computer.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" version="1.1">
     <rect style="opacity:0.2" width="12" height="16" x="5" y="4.5" rx="1" ry="1"/>
     <rect style="fill:#999999" width="12" height="16" x="5" y="4" rx="1" ry="1"/>
     <rect style="opacity:0.2" width="20" height="16" x="1" y="2.5" rx="1" ry="1"/>
     <path style="fill:#6b6b6b" d="M 1 16 L 1 17 C 1 17.554 1.446 18 2 18 L 20 18 C 20.554 18 21 17.554 21 17 L 21 16 L 1 16 z"/>
     <path style="fill:#585858" d="M 2,2 C 1.446,2 1,2.446 1,3 V 16 H 21 V 3 C 21,2.446 20.554,2 20,2 Z"/>
     <rect style="opacity:0.1;fill:#ffffff" width="20" height=".5" x="1" y="16"/>
     <path style="opacity:0.1;fill:#ffffff" d="M 2,2 C 1.446,2 1,2.446 1,3 v 0.5 c 0,-0.554 0.446,-1 1,-1 h 18 c 0.554,0 1,0.446 1,1 V 3 C 21,2.446 20.554,2 20,2 Z"/>
    </svg>
  '';
  # one scalable copy, matched before the lookup falls through to papirus-dark, so it wins at every size.
  iconThemePkg = pkgs.runCommandLocal "papirus-dark-eric" { } ''
    base=$out/share/icons/${iconTheme}
    mkdir -p "$base/scalable/devices"
    cp ${computerSvg} "$base/scalable/devices/computer.svg"
    {
      echo "[Icon Theme]"
      echo "Name=${iconTheme}"
      echo "Inherits=Papirus-Dark"
      echo "Directories=scalable/devices"
      echo
      echo "[scalable/devices]"
      echo "Context=Devices"; echo "Size=22"; echo "MinSize=8"; echo "MaxSize=512"; echo "Type=Scalable"
    } > "$base/index.theme"
  '';
in

{
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name    = "Bibata-Modern-Classic";
    size    = 20;
    sway.enable = true; # writes seat "*" { xcursor_theme = "..."; } into the sway config
  };

  # enabling gtk hands home-manager the settings.ini, so every pref has to be set here.
  # prefer-dark keeps thunar etc dark, primary-paste off kills middle-click paste.
  gtk = {
    enable = true;
    # papirus-dark icon theme, light-on-dark for the dark desktop
    iconTheme = {
      name = iconTheme;
      package = iconThemePkg;
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

  home.packages = [
    pkgs.papirus-icon-theme # the base theme the computer-icon overlay inherits from
  ];
}
