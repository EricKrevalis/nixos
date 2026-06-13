{ config, lib, pkgs, ... }:

# dev and gaming layer on top of extended
# enabled by host.specialized
lib.mkIf config.host.specialized {
  # 32-bit GL for Steam/Proton
  hardware.graphics.enable32Bit = true;

  environment.systemPackages = with pkgs; [
    claude-code
  ];
}
