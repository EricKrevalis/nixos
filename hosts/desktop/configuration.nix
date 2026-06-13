{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  services.printing.enable = true;

  system.stateVersion = "26.05";
}
