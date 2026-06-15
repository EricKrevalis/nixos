{ ... }:

# layers and hardware toggles live in flake.nix common, not here
{
  imports = [
    ./hardware-configuration.nix
  ];

  # services.printing.enable = true; # uncomment for network printers

  system.stateVersion = "26.05";
}
