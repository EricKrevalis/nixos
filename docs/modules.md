# modules

what each module holds and where new things go. paths are under `core/`.

## modules/base.nix

every host gets this:

- bootloader (systemd-boot)
- networking (NetworkManager)
- locale and timezone
- tty autologin plus sway launch via `loginShellInit`
- hardware.graphics (mesa, accelerated GL)
- pipewire audio stack
- openssh (key generation only, firewall closed)
- file manager stack: thunar plus volman and archive plugins, gvfs, tumbler, udisks2
- bluetooth
- firefox
- xdg portals, soteria polkit agent
- core cli packages: neovim, git, alacritty, fuzzel, bluetui, wiremix, btop, trashy,
  clipboard, screenshot and media-key tooling, waybar
- zsh system wide so it works as the login shell
- sops-nix age key config
- nix flakes, store optimization, weekly gc

## modules/polish.nix

enabled by `host.polish`. the polished feature complete desktop on top of base. empty
placeholder for now, base already covers a usable desktop.

## modules/specialized/dev.nix

enabled by `host.dev`:

- dev tools (currently claude-code)

the home-side counterpart `home/specialized/dev.nix` adds delta and lazygit.

## modules/specialized/gaming.nix

enabled by `host.gaming`:

- 32-bit GL (`hardware.graphics.enable32Bit`) for Steam/Proton

## modules/specialized/nvidia.nix

enabled by `host.nvidia`:

- proprietary nvidia driver
- modesetting
- open kernel modules
- wlroots env vars, set via `loginShellInit` in base.nix, gated on this toggle

## modules/toggles.nix

typed boolean schema for the `host.*` toggles. a wrong value fails at eval, not at runtime,
and it is the one place to see what knobs exist.

## where new things go

| what | where |
|------|-------|
| works on any machine | `base.nix` or `home/base.nix` |
| polished desktop, daily use | `polish.nix` |
| dev tools | `specialized/dev.nix` (or `home/specialized/dev.nix`) |
| gaming | `specialized/gaming.nix` |
| gpu specific | `specialized/nvidia.nix` or a new hardware module |
| one machine only | `hosts/<host>/configuration.nix` or `hosts/<host>/home.nix` |
| new toggle | add to `toggles.nix`, `flake.nix` common, and the relevant module |
