{ settings, lib, ... }:

{
  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  # one block per git host from settings.sshIdentities, IdentitiesOnly so the agent
  # never offers the wrong key. the identities live in flake.nix common, this stays generic.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*".AddKeysToAgent = "yes";
    } // lib.mapAttrs (host: keyfile: {
      HostName = host;
      User = "git";
      IdentityFile = "~/.ssh/${keyfile}";
      IdentitiesOnly = true;
    }) settings.sshIdentities;
  };

  programs.git = {
    enable = true;
    package = null; # git is installed system-wide; home-manager only writes the config
    settings = {
      user.email = settings.gitEmail;
      user.name = settings.gitName;
      init.defaultBranch = "main";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # sway base. per-host monitor layout lives in hosts/<host>/home.nix.
  # the session launch is system-level (modules/basic.nix), not here.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway.enable
    config = {
      modifier = "Mod4"; # Super key
      terminal = "alacritty";
      menu = "fuzzel"; # Super+D launcher (native wayland, no xwayland)
    };
  };

  home.stateVersion = "26.05";
}
