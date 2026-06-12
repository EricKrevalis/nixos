{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # Temporary: KDE Plasma 6 until Sway is set up (Hyprland was dropped)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # GPU: NVIDIA RTX 3060 Ti (Ampere). Needed for Wayland (KDE/Sway) + gaming.
  # ▶ CURRENTLY TESTING: stable branch + open kernel modules (open = true).
  # Note: both open=true/false use the proprietary userspace driver (neither is
  # nouveau); `open` only swaps the kernel module. The old Linux Mint setup ran
  # the CLOSED modules (open=false) well, so this open=true run is the experiment.
  # If this build misbehaves (flicker, black screen, suspend issues): roll back to
  # the previous generation from the boot menu, then try open=false and/or another
  # branch (production/beta/latest).
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit GL for Steam/Proton
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true; # required for Wayland; enables explicit sync path
    open = true;               # TESTING open kernel modules (vs closed, which Mint ran well)
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable; # TESTING stable branch
    powerManagement.enable = false; # enable only if suspend/resume corrupts the display
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.eric = {
    isNormalUser = true;
    description = "eric";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh; # HM configures zsh; this makes it the actual login shell
  };

  # Enabling zsh system-wide is required for users.users.eric.shell = pkgs.zsh
  # to work cleanly (sets up /etc/shells and completion).
  programs.zsh.enable = true;

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    claude-code
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "26.05";
}
