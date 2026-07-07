{ settings, lib, pkgs, ... }:

# work tooling, enabled by the work toggle in flake.nix
lib.mkIf settings.work {
  environment.systemPackages = [
    pkgs.eduvpn-client # browser login then a rotating-key wireguard tunnel, runs as eduvpn-gui
    pkgs.teams-for-linux # electron wrapper, no native linux client anymore
  ];

  # strict reverse path filtering drops eduvpn's wireguard return traffic, loosen it
  networking.firewall.checkReversePath = "loose";

  # eduvpn's tunnel ipv6 is an unreachable ula, rank it below ipv4 so it isn't tried first.
  # native global v6 still outranks ipv4.
  # any precedence entry replaces glibc's default table, so the standard rows are restated.
  networking.getaddrinfo.precedence = {
    "::1/128" = 50;
    "::/0" = 40;
    "2002::/16" = 30;
    "::/96" = 20;
    "::ffff:0:0/96" = 10;
    "fc00::/7" = 3;
  };
}
