{ settings, lib, ... }:

# home-side dev tooling, gated like core/modules/specialized/dev.nix.
lib.mkIf settings.dev {
  # delta wires into git as the diff pager, so it belongs here, not in systemPackages.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;     # n and N jump between diff sections
      line-numbers = true;
    };
  };

  # use delta as lazygit's pager too
  programs.lazygit = {
    enable = true;
    settings.git.paging = {
      colorArg = "always";
      pager = "delta --paging=never";
    };
  };
}
