{ ... }:

# replace this file before building, generate your own with:
#   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
# until you do the build fails on purpose. nixos refuses to build a system with no root
# filesystem, so you cannot switch into a generation that will not boot.
{ }
