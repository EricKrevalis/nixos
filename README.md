# nixos

my nixos setup for `desktop` (and later `laptop`).
flake based, home manager runs as a nixos module.
one settings block per host, the rest is shared modules.

## rebuilding

```bash
nrs   # sudo nixos-rebuild switch --flake ~/.config/nixos
nrb   # same but boot, applies on next reboot
```

the repo lives at `~/.config/nixos` and i reference it explicitly, no `/etc/nixos` symlink.
the aliases are defined in `home/shell.nix`.
with no `#attr` on the flake, nixos-rebuild picks the config matching my hostname.
see `docs/bootstrap.md` for the first build on a fresh install (where the aliases do not exist yet).

## how it fits together

every host is one call to `mkHost` in `flake.nix`.
it takes a `settings` attrset (`common` merged with per-host overrides) and threads it into every module.
so everything a machine changes is in that one block:

```nix
desktop = mkHost (common // {
  hostname = "desktop";
  nvidia   = true;   # proprietary nvidia stack
  gaming   = true;   # steam, gamescope, gamemode, vesktop
  work     = true;   # eduvpn, teams
  arkenfox = true;   # hardened firefox profile
});
```

each optional module gates itself on its boolean, a misspelled name fails at eval instead of being silently ignored.
everything else is always on: this system is built to work as one piece, so it ships as one piece.
only the parts that genuinely split off cleanly are toggles, hardware (`nvidia`) and machine roles (`gaming`, `work`, `arkenfox`).

## layout

```
flake.nix / flake.lock   inputs, the common settings block, one mkHost per machine
modules/                 system side, one file per domain, default.nix imports them all
  optional/              the toggled modules: gaming, nvidia, work
home/                    home manager side, one file per program, default.nix imports them all
  optional/              the toggled modules: gaming, arkenfox
configs/                 raw config files wired in from modules/ and home/ (nvim, waybar, firefox)
hosts/nixos/             empty starter host a fork begins from
hosts/<host>/            my machines: hardware-configuration.nix, configuration.nix, home.nix
  configs/               raw configs only that machine uses (goxlr, wireplumber)
docs/                    my own notes, not read by nix
```

finding things: `modules/default.nix` and `home/default.nix` are the tables of contents, every file is named for the domain or program it configures.

## using this on your own machine

start your own config from mine:

```bash
nix flake init -t github:EricKrevalis/nixos
```

that copies this whole repo into an empty dir. then:

1. delete `hosts/desktop` and `hosts/surface`, they describe my hardware
2. edit `flake.nix` `common` with your name, email, timezone
3. uncomment the `nixos` host entry, flip the toggles you want
4. generate your hardware config:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
   ```
5. `sudo nixos-rebuild switch --flake .#nixos`

the build fails until step 4 is done, that is on purpose.
nixos will not build a system with no root filesystem, so you cannot switch into a generation that will not boot.

rebuilding one of my actual machines straight from github, no clone needed:

```bash
sudo nixos-rebuild switch --flake github:EricKrevalis/nixos#desktop
```

## conventions

anything that changes the system goes through nix, so the file in the repo is the live one.
no hand editing the running copy.

- config files: keep the real file in `configs/`, point at it from the module:
  ```nix
  xdg.configFile."waybar/style.css".source = ../configs/waybar/style.css;
  ```
- scripts are packaged onto PATH with `writeShellApplication` next to the program they belong to (the power menu lives in `home/fuzzel.nix`)
- `docs/` is just notes for me, nothing there affects the build

github actions evaluates the flake on every push (`.github/workflows/check.yml`).
