{ settings, lib, pkgs, ... }:

# home-side dev tooling, gated like core/modules/specialized/dev.nix.
lib.mkIf settings.dev {

  # claude-code fullscreen (alternate-screen) renderer, the declarative equivalent of /tui fullscreen
  home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";

  # fuzzy finder. fd backs the file/dir widgets so Ctrl+T and Alt+C honor .gitignore and skip hidden files.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";
    defaultOptions = [ "--height 40%" "--layout reverse" "--border" ];
  };

  # delta wires into git as the diff pager, so it belongs here, not in systemPackages.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;     # n and N jump between diff sections
      line-numbers = true;
    };
  };

  # delta as lazygit's pager. pagers array, not the old paging object (0.62+)
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --paging=never";
        }
      ];
    };
  };
}
