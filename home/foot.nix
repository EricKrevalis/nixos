{ lib, ... }:

{
  # the HM foot module ships its own package, so foot comes from here, not systemPackages.
  # server mode left off, enable it later if terminal startup ever feels slow.
  programs.foot = {
    enable = true;
    settings = {
      main = {
        # default font, stylix replaces it when enabled
        font = lib.mkDefault "AtkynsonMono Nerd Font Mono:size=12";
        # don't auto-copy a selection anywhere (default is primary), the primary-selection path is retired.
        selection-target = "none";
      };
      # shift+enter emits a newline byte (0x0a) instead of submitting, plain enter still sends CR
      text-bindings."\\x0a" = "Shift+Return";
      # no middle-click paste either, the primary-selection mouse path is retired
      mouse-bindings.primary-paste = "none";
    };
  };

  # exo has no built-in helper for foot, so thunar's "open terminal here" errors out
  xdg.dataFile."xfce4/helpers/foot.desktop".text = ''
    [Desktop Entry]
    Type=X-XFCE-Helper
    X-XFCE-Category=TerminalEmulator
    Name=Foot
    X-XFCE-Commands=foot
    X-XFCE-CommandsWithParameter=foot %s
  '';
  xdg.configFile."xfce4/helpers.rc".text = "TerminalEmulator=foot\n";
}
