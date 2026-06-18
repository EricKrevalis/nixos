{ config, lib, pkgs, ... }:

# dev tools layer on top of polish, enabled by host.dev
lib.mkIf config.host.dev {
  environment.systemPackages = with pkgs; [
    claude-code
  ];
}
