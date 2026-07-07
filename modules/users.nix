{ settings, pkgs, ... }:

{
  users.users.${settings.username} = {
    isNormalUser = true;
    description = settings.username;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh; # home-manager configures zsh, this makes it the login shell
  };
  # zsh must be enabled system-wide for the login shell above (adds /etc/shells, completion).
  programs.zsh.enable = true;
}
