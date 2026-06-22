{ config, lib, pkgs, ... }:

# feature complete desktop on top of base, enabled by host.polish
lib.mkIf config.host.polish {
  environment.systemPackages = with pkgs; [
    mullvad-browser # safe-by-default second browser, base ships firefox as the actual default web handler
    btop # resource monitor tui
    cliphist # clipboard history, the watcher and picker keybind live in home polish
  ];
}
