{ settings, lib, pkgs, ... }:

# gaming stack, enabled by the gaming toggle in flake.nix
lib.mkIf settings.gaming {
  programs.steam = {
    enable = true; # also pulls in 32-bit graphics
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # newest GE-Proton, pick per game in steam
  };

  # capSysNice off, the cap_sys_nice wrapper fails under steam launch options
  # steam sets no_new_privs, the game can't inherit the cap so it exits (nixpkgs#351516)
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  # per-title cpu governor + scheduling boost, add gamemoderun to a game's launch options
  programs.gamemode.enable = true;

  # gamemode's polkit rule only grants cpugovctl/procsysctl to this group, membership is never automatic
  users.users.${settings.username}.extraGroups = [ "gamemode" ];

  # some proton titles crash on the default mmap limit, steamos/fedora ship this value
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  # discord fork with working wayland screen share and audio
  environment.systemPackages = [ pkgs.vesktop ];
}
