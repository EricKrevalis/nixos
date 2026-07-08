{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    git
    fuzzel # launcher
    bluetui # bluetooth tui
    wiremix # audio tui
    trashy # recoverable delete
    wl-clipboard # wayland clipboard tools
    libnotify # notify-send for scripted notifications
    grim # wayland screenshot capture
    slurp # region selector, pairs with grim
    satty # screenshot annotation
    playerctl # media key control (MPRIS)
    waybar        # status bar
    swaybg        # wallpaper renderer for sway
    (callPackage ../configs/autotile { }) # autotiler, sets split direction from the focused window's live geometry
    swayimg # image viewer
    xarchiver # archive manager, thunar right-click frontend
    p7zip # 7z and zip backend xarchiver calls (maintained 17.06 fork)
    unrar # rar extraction backend (nonfree)
    unzip # zip extraction
    zip # zip creation
    mullvad-browser # safe-by-default second browser, firefox is the actual default web handler
    btop # resource monitor tui, themed config in home/btop.nix
    cliphist # clipboard history, the watcher and picker keybind are home-side
    claude-code
    fd # faster friendlier find, backs the fzf widgets and telescope find-files
    ripgrep # fast grep, backs telescope live-grep
    tree # directory listing as a tree
    # global toolchains for scratch files, projects pin their own via devShells.
    # python comes from the home-side jupyter env
    rustc
    cargo
    clippy
    gcc
    nodejs # also runs the markdown-preview.nvim server
  ];

  nixpkgs.config.allowUnfree = true;
  # pnpm builds the electron apps and never lands in the system, the CVEs target interactive use.
  # drop once nixpkgs moves pnpm_10 past 10.29.2
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];

  # keep man pages, skip the nixos manual rebuild and the html/info trees
  documentation = {
    nixos.enable = false;
    doc.enable = false;
    info.enable = false;
  };
}
