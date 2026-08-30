{ settings, ... }:

{
  programs.git = {
    enable = true;
    package = null; # git is installed system-wide, home-manager only writes the config
    settings = {
      user.email = settings.gitEmail;
      user.name = settings.gitName;
      init.defaultBranch = "main";
    };
  };

  # delta as git's diff pager, home-side to stay next to the git config, not in systemPackages
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
      git.diffRenderers = [
        {
          colorArg = "always";
          command = "delta --paging=never";
        }
      ];
    };
  };
}
