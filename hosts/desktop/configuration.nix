{ settings, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # services.printing.enable = true; # no printer on this machine, uncomment to add one

  # internal drives, always present on this machine
  fileSystems."/run/media/eric/work" = {
    device = "/dev/disk/by-label/work";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
  fileSystems."/run/media/eric/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # setup details worth keeping out of a public repo live encrypted. each secret is a config
  # fragment its consumer includes at runtime, sops decrypts them at activation. see
  # docs/secrets.md for the contents and how to edit them.
  sops.secrets = {
    "ssh-work" = {
      sopsFile = ../../secrets/ssh-work.yaml;
      key = "conf";
      owner = settings.username; # read by ssh in the user session
    };
    "sway-outputs" = {
      sopsFile = ../../secrets/sway-outputs.yaml;
      key = "conf";
      owner = settings.username; # read by sway in the user session
    };
    "wireplumber-priority" = {
      sopsFile = ../../secrets/wireplumber-priority.yaml;
      key = "conf";
      mode = "0444"; # read by wireplumber in the user session
      path = "/etc/wireplumber/wireplumber.conf.d/99-default-priority.conf";
    };
    "wireplumber-declutter" = {
      sopsFile = ../../secrets/wireplumber-declutter.yaml;
      key = "conf";
      mode = "0444";
      path = "/etc/wireplumber/wireplumber.conf.d/99-audio-declutter.conf";
    };
  };

  # sops drops the wireplumber fragments here, the dir has to exist first
  systemd.tmpfiles.rules = [ "d /etc/wireplumber/wireplumber.conf.d 0755 root root -" ];

  system.stateVersion = "26.05";
}
