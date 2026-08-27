{ settings, lib, pkgs, ... }:

# work tooling, enabled by the work toggle in flake.nix
lib.mkIf settings.work {
  environment.systemPackages = [
    pkgs.eduvpn-client # browser login then a rotating-key wireguard tunnel, runs as eduvpn-gui
    pkgs.teams-for-linux # electron wrapper, no native linux client anymore
    pkgs.bun # js/ts runtime + package manager
    pkgs.zotero # reference manager
  ];

  # tailscale for direct access to jupyter clusters, instead of going through jupyterlab in the browser
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # local llm inference on the 3060 ti
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

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
