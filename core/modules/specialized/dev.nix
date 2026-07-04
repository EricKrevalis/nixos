{ config, lib, pkgs, ... }:

# dev tools layer on top of polish, enabled by host.dev
lib.mkIf config.host.dev {
  environment.systemPackages = with pkgs; [
    claude-code
    fd # faster friendlier find, backs the fzf widgets and telescope find-files
    ripgrep # fast grep, backs telescope live-grep
    bat # cat with syntax highlighting
    # global toolchains for scratch files, projects pin their own via devShells.
    # python comes from the home-side jupyter env
    rustc
    cargo
    clippy
    gcc
    nodejs
  ];
}
