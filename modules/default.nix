{ ... }:

# system entry point, every host imports this.
# one file per domain, always on. optional/ holds the toggled modules,
# each gated on its settings.* boolean from flake.nix.
{
  imports = [
    ./boot.nix # systemd-boot
    ./network.nix # networkmanager, openssh, syncthing
    ./locale.nix # timezone, locale split
    ./desktop.nix # swayfx, soteria, swaylock pam, xdg portals, screenshare patches, launch hooks
    ./audio.nix # pipewire, bluetooth
    ./storage.nix # thunar, udisks2, gvfs, tumbler, fwupd
    ./fonts.nix # noto, atkynson mono
    ./stylix.nix # base16 forest palette
    ./packages.nix # neovim, git, cli tools, screenshot stack, archive stack, toolchains
    ./users.nix # user account, zsh
    ./nix.nix # flakes, gc, sops key path
    ./optional/gaming.nix # steam, gamescope, gamemode, vesktop
    ./optional/nvidia.nix # nvidia driver, wlroots quirks, btop wrapper
    ./optional/work.nix # eduvpn, teams
    ./optional/laptop.nix # brightnessctl
  ];
}
