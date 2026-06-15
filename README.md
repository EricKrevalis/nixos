# nixos

my nixos setup for `desktop` (and later `laptop`). flake based, home manager runs as a
nixos module. one settings block per host, the rest is shared modules in opt-in layers.

## rebuilding

```bash
nrs   # sudo nixos-rebuild switch --flake ~/.config/nixos
nrb   # same but boot, applies on next reboot
```

the repo lives at `~/.config/nixos` and i reference it explicitly, no `/etc/nixos`
symlink. the aliases are defined in `home/basic.nix`. with no `#attr` on the flake,
nixos-rebuild picks the config matching my hostname. see `docs/bootstrap.md` for the first
build on a fresh install (where the aliases do not exist yet).

## how it fits together

every host is one call to `mkHost` in `flake.nix`. it takes a `settings` attrset (`common`
merged with per-host overrides) and threads it into every module. so the whole surface for
a machine is that one block:

```nix
desktop = mkHost (common // {
  hostname = "desktop";
  nvidia   = true;   # proprietary nvidia stack
  polish   = true;   # polished, feature complete desktop
  dev      = true;   # dev tools on top
  gaming   = true;   # gaming on top
});
```

those booleans are typed in `core/modules/toggles.nix`, so a wrong value is a build error,
not a silent no-op. the software stacks in layers, each one opt in per host:

- base     every host, base system plus sway. `core/modules/base.nix`
- polish   polished, feature complete desktop. `core/modules/polish.nix`
- dev      dev tools on top of polish. `core/modules/specialized/dev.nix`
- gaming   gaming on top of polish. `core/modules/specialized/gaming.nix`

nvidia is a separate hardware toggle (`core/modules/specialized/nvidia.nix`), inert unless
`nvidia = true`. non nvidia machines run the default mesa stack and set nothing.

## layout

```
flake.nix / flake.lock   inputs, the common settings block, one mkHost per machine
core/                    the shared engine, also the fork template (see below)
  flake.nix              standalone starter flake a fork builds on
  modules/               base, polish, toggles, specialized/{dev,gaming,nvidia}
  home/                  home manager base, plus specialized/dev
  configs/               raw config files wired in from home (waybar)
  hosts/nixos/           stub host a fork replaces with its own hardware
hosts/<host>/            my machines: hardware-configuration.nix, configuration.nix, home.nix
configs/                 my host-specific raw configs (wireplumber)
docs/                    my own notes, not read by nix
```

## using this on your own machine

scaffold your own config from mine:

```bash
nix flake init -t github:EricKrevalis/nixos
```

that copies the `template/` starter into an empty dir, just the engine, none of my hosts.
then:

1. edit `flake.nix` `common` with your name, email, timezone, hostname
2. flip the layers you want (`polish`, `dev`, `gaming`, `nvidia`)
3. generate your hardware config:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
   ```
4. `sudo nixos-rebuild switch --flake .#nixos`

the build fails until step 3 is done, that is on purpose. nixos will not build a system
with no root filesystem, so you cannot switch into a generation that will not boot.

rebuilding one of my actual machines straight from github, no clone needed:

```bash
sudo nixos-rebuild switch --flake github:EricKrevalis/nixos#desktop
```

## conventions

anything that changes the system goes through nix, so the file in the repo is the live one.
no hand editing the running copy.

- config files: keep the real file in `configs/`, point at it from home:
  ```nix
  xdg.configFile."waybar/config".source = ./configs/waybar/config;
  ```
- scripts: keep them in `scripts/`, package them onto PATH:
  ```nix
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "name" (builtins.readFile ./scripts/name.sh))
  ];
  ```
- `docs/` is just notes for me, nothing there affects the build

## the core/ engine and the template

`core/` is the one copy of the engine. my real hosts at the repo root import it
(`./core/modules/base.nix`), and `templates.default` points at the same `core/`, so the
fork starter and what actually runs can never drift, there is nothing to keep in sync.

a fork gets `core/` as its whole repo: a working `flake.nix`, the modules, the home config,
and a stub host to fill in. my own `flake.nix`, `hosts/`, and host-specific `configs/` stay
at the root and never ship.

github actions evaluates the flake on every push (`.github/workflows/check.yml`), which
covers the whole engine since the real hosts import it.
