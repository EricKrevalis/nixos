{ settings, ... }:

{
  networking.hostName = settings.hostname;
  networking.networkmanager.enable = true; # ships nmtui for terminal Wi-Fi management
  networking.modemmanager.enable = false; # no cellular modem, networkmanager enables it by default

  services.openssh = {
    enable = true;
    openFirewall = false; # no incoming connections, host key generation only
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # file sync with the surface: no systemd service, just the package.
  # run manually with `syncthing`, same habit as on Mint.
  # GUI defaults to localhost:8384 once running.
  services.syncthing = {
    enable = true;
    systemService = false;
  };
}
