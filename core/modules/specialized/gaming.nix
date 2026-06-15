{ config, lib, ... }:

# gaming layer on top of polish, enabled by host.gaming
lib.mkIf config.host.gaming {
  hardware.graphics.enable32Bit = true; # required for Steam/Proton
}
