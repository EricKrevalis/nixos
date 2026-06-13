{ ... }:

{
  # monitor layout is kept private, the real output and workspace directives live in the
  # sops secret sway-outputs and get pulled in at sway startup
  wayland.windowManager.sway.extraConfig = "include /run/secrets/sway-outputs";

  # private ssh identity, decrypted by sops, wired in hosts/desktop/configuration.nix
  programs.ssh.includes = [ "/run/secrets/ssh-work" ];

  # generic audio drop-in only, the device specific ones are sops secrets in /etc
  xdg.configFile."wireplumber/wireplumber.conf.d".source = ../../configs/wireplumber;
}
