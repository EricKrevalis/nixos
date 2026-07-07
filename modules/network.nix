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
}
