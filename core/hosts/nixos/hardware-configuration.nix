{ ... }:

# replace before building, generate with:
#   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
# build fails on purpose until then, nixos refuses a system with no root filesystem.
{ }
