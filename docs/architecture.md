# architecture

## the flake

`flake.nix` holds a `common` attrset shared by every host (username, timezone, locale, git
config, tier toggles) and a `mkHost` function that builds a nixos system from `common`
merged with per-host overrides.

the merged result is `settings`, threaded into every module through `specialArgs`. so any
module can read `settings.username`, `settings.nvidia` and so on without importing anything.

## software tiers

the stack layers bottom to top, each tier opt in per host:

- basic, base system plus sway, audio, bluetooth, core cli tools. every host gets this.
- extended, feature complete desktop: file manager, printing, daily use bits.
- specializedDev, dev tools on top of extended.
- specializedGame, gaming tools and 32-bit GL on top of extended.

`nvidia` is a separate hardware toggle, not a tier. it pulls in the proprietary driver and
sets the wlroots env vars sway needs on that gpu.

the toggles live in `flake.nix` per host:

```nix
desktop = mkHost (common // {
  hostname        = "desktop";
  nvidia          = true;
  extended        = true;
  specializedDev  = true;
  specializedGame = true;
});
```

`modules/options.nix` types them as booleans, so a wrong value is a build error.

## module layout

```
modules/
  options.nix           typed schema for the host.* toggles
  basic.nix             always loaded, conditionally imports the rest
  extended.nix          guarded by host.extended
  specialized-dev.nix   guarded by host.specializedDev
  specialized-game.nix  guarded by host.specializedGame
  nvidia.nix            guarded by host.nvidia
```

host specific config (hardware, drive mounts, monitor layout) lives under `hosts/<host>/`,
not in the modules. the modules stay portable across machines.

## home manager

home manager runs as a nixos module so it rebuilds with the system. each host gets:

- `home/basic.nix`, shared user config: git, zsh, ssh, sway base.
- `hosts/<host>/home.nix`, per-host overrides: monitor layout, device specific bits.

## template

`template/` is a self contained forkable copy of the engine, exposed as `templates.default`:

```bash
nix flake init -t github:EricKrevalis/nixos-config
```

`scripts/sync-template.sh` mirrors the real modules into `template/`. a pre commit hook and
CI both run `--check` so it cannot drift.
