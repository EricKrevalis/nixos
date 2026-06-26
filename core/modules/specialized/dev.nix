{ config, lib, pkgs, ... }:

# dev tools layer on top of polish, enabled by host.dev
lib.mkIf config.host.dev {
  environment.systemPackages = with pkgs; [
    claude-code
    fd # faster friendlier find, backs the fzf widgets and telescope find-files
    ripgrep # fast grep, backs telescope live-grep
    bat # cat with syntax highlighting
  ];
}
