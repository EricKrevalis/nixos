# modules

what each file holds and where new things go.
`modules/default.nix` and `home/default.nix` are the tables of contents, this is the prose version.

## modules/ (system side, one file per domain, all always on)

- `boot.nix`: systemd-boot.
- `network.nix`: hostname, NetworkManager, openssh (key generation only, firewall closed).
- `locale.nix`: timezone plus the en_US/en_DK/en_IE locale split.
- `desktop.nix`: the session. tty autologin, sway launch via `loginShellInit`, swayfx, hardware.graphics, xdg portals (with the screenshare patches), soteria polkit agent, swaylock pam. also declares the launch hooks (`host.sessionPreExec`, `host.swayLaunchArgs`) the nvidia module fills.
- `audio.nix`: pipewire stack, bluetooth.
- `storage.nix`: thunar plus volman and archive plugins, gvfs, tumbler, udisks2, fwupd toggle (off).
- `fonts.nix`: the explicit font set, default packages off.
- `stylix.nix`: system-wide theming, the forest base16 palette.
- `packages.nix`: system packages (core cli, desktop tooling, global toolchains) and the nixpkgs config.
- `users.nix`: the user account, zsh system wide so it works as the login shell.
- `nix.nix`: flakes, store optimization, weekly gc, sops-nix age key config.

## modules/optional/ (toggled)

- `gaming.nix` (`gaming`): steam + GE-Proton, gamescope, gamemode, vesktop, 32-bit GL, vm.max_map_count bump.
- `nvidia.nix` (`nvidia`): proprietary driver, modesetting, open kernel modules, the wlroots env vars and `--unsupported-gpu` fed through the launch hooks.
- `work.nix` (`work`): eduvpn client, teams, the vpn network tweaks.

## home/ (one file per program, all always on)

each file is named for the program it configures, so the answer to "how is X set up" is `home/X.nix`.
the exceptions that bundle a bit more:

- `theme.nix`: gtk dark, icon theme, cursor.
- `shell.nix`: zsh, starship, zoxide, fzf, direnv.
- `mime.nix`: default apps plus the iso-mount helper.
- `waybar.nix`: the bar, also declares `host.persistentWorkspaces`, the workspace map a host fills in its `home.nix` next to the monitor layout.
- `nvim.nix`: the editor tooling (grammars, lsp servers, formatters), the lua config is an out-of-store symlink to `configs/nvim`.

## home/optional/ (toggled)

- `gaming.nix` (`gaming`): steam fullscreen rule, mangohud.
- `arkenfox.nix` (`arkenfox`): the hardened firefox profile, user.js, ublock, theme.

## where new things go

| what | where |
|------|-------|
| a system domain setting | the matching `modules/<domain>.nix` |
| a new program's user config | a new `home/<program>.nix`, imported in `home/default.nix` |
| gaming | `modules/optional/gaming.nix` or `home/optional/gaming.nix` |
| gpu specific | `modules/optional/nvidia.nix` or a new hardware module |
| one machine only | `hosts/<host>/configuration.nix` or `hosts/<host>/home.nix` |
| new toggle | a boolean in `flake.nix` common, `lib.mkIf settings.<toggle>` in the module |
