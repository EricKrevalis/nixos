{ pkgs, ... }:

{
  home.username = "eric";
  home.homeDirectory = "/home/eric";

  programs.git = {
    enable = true;
    settings = {
      user.email = "eric.krevalis@gmail.com";
      user.name = "eric";
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

  home.stateVersion = "26.05";
}
