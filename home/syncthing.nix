{ ... }:

{
  services.syncthing = {
    enable = true; # user service, starts on login
    # gui owns devices and folders, keeps device ids out of the repo
    overrideDevices = false;
    overrideFolders = false;
  };
}
