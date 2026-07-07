{ lib, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # rebuild shortcuts. flake referenced explicitly, no /etc/nixos symlink.
    # no #attr, so nixos-rebuild builds nixosConfigurations.<hostname> for the current host.
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos";
      nrb = "sudo nixos-rebuild boot --flake ~/.config/nixos";
    };
    initContent = lib.mkMerge [
      ''
        export PATH="$HOME/.local/bin:$PATH"
      ''
      # --cmd cd makes cd a frecency-aware superset of the builtin, real paths still work
      (lib.mkAfter ''
        eval "$(zoxide init zsh --cmd cd)"
      '')
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # the nerd-font-symbols preset is the bulk of the config, kept as data in configs/starship.
    # refresh it after a starship upgrade: starship preset nerd-font-symbols > that file.
    # the tweaks below override it, recursiveUpdate's second arg wins on conflict.
    settings = lib.recursiveUpdate
      (builtins.fromTOML (builtins.readFile ../configs/starship/nerd-font-symbols.toml))
      {
        add_newline = false;    # no blank line between prompts, keeps it compact
        command_timeout = 1000; # ms before a slow module is skipped, avoids prompt stalls
        # » arrow, forest green on success and burnt orange when the last command failed
        character = {
          success_symbol = "[»](#346b30)";
          error_symbol = "[»](#bc4e20)";
        };
      };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # init by hand in initContent, must run after starship
  };

  # fuzzy finder. fd backs the widgets, so Ctrl+T and Alt+C honor .gitignore and skip hidden files
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    fileWidget.command = "fd --type f";
    changeDirWidget.command = "fd --type d";
    defaultOptions = [ "--height 40%" "--layout reverse" "--border" ];
  };

  # a repo's .envrc loads its devShell on cd, unloads on leave.
  # nix-direnv caches the shell, instant re-entry, safe from gc
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # claude-code fullscreen (alternate-screen) renderer, the declarative equivalent of /tui fullscreen
  home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";
}
