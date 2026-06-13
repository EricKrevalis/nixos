# modules

what each module holds and where new things go.

## basic.nix

every host gets this:

- bootloader (systemd-boot)
- networking (NetworkManager)
- locale and timezone
- tty autologin plus sway launch via `loginShellInit`
- hardware.graphics (mesa, accelerated GL)
- pipewire audio stack
- openssh (key generation only, firewall closed)
- udisks2 (drive mounting backend)
- bluetooth
- firefox
- core cli packages: neovim, git, alacritty, fuzzel, bluetui, wiremix
- zsh system wide so it works as the login shell
- sops-nix age key config
- nix flakes, store optimization, weekly gc

## extended.nix

enabled by `host.extended`:

- thunar file manager plus volman and archive plugins
- gvfs (trash, MTP, network locations)
- tumbler (thumbnails)

## specialized-dev.nix

enabled by `host.specializedDev`:

- dev tools (currently claude-code)

## specialized-game.nix

enabled by `host.specializedGame`:

- 32-bit GL (`hardware.graphics.enable32Bit`) for Steam/Proton

## nvidia.nix

enabled by `host.nvidia`:

- proprietary nvidia driver
- modesetting
- open kernel modules
- wlroots env vars, set via `loginShellInit` in basic.nix, gated on this toggle

## options.nix

typed boolean schema for the `host.*` toggles. a wrong value fails at eval, not at runtime,
and it is the one place to see what knobs exist.

## where new things go

| what | where |
|------|-------|
| works on any machine | `basic.nix` or `home/basic.nix` |
| desktop gui, daily use | `extended.nix` |
| dev tools | `specialized-dev.nix` |
| gaming | `specialized-game.nix` |
| gpu specific | `nvidia.nix` or a new hardware module |
| one machine only | `hosts/<host>/configuration.nix` or `hosts/<host>/home.nix` |
| new toggle | add to `options.nix`, `flake.nix` common, and the relevant module |
