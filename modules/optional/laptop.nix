{ settings, pkgs, lib, ... }:

# laptop-specific tooling, enabled by the laptop toggle in flake.nix
lib.mkIf settings.laptop {
  programs.sway.extraPackages = with pkgs; [ brightnessctl ];
}
