{ settings, ... }:

# home entry point, every host imports this.
# one file per program, always on. optional/ holds the toggled modules.
{
  imports = [
    ./theme.nix # cursor, gtk dark, papirus icons
    ./shell.nix # zsh, starship, zoxide, fzf, direnv
    ./ssh.nix # one identity block per git host
    ./git.nix # git config, delta, lazygit
    ./foot.nix # terminal
    ./fuzzel.nix # launcher, power menu
    ./sway.nix # compositor config, clipboard history
    ./swaylock.nix # screen lock
    ./waybar.nix # status bar
    ./mako.nix # notifications
    ./gammastep.nix # night light
    ./firefox.nix # default browser
    ./zathura.nix # pdf and epub reader
    ./mpv.nix # media player
    ./mime.nix # default apps, iso mounting
    ./satty.nix # screenshot annotation
    ./userdirs.nix # xdg dirs, usb automount
    ./tidal.nix # music streaming
    ./nvim.nix # editor tooling, treesitter, lsp, formatters
    ./jupyter.nix # notebooks
    ./optional/gaming.nix # mangohud, steam window rule
    ./optional/arkenfox.nix # hardened firefox profile
  ];

  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  home.stateVersion = "26.05";
}
