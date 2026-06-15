# architecture

## the flake

`flake.nix` holds a `common` attrset shared by every host (username, timezone, locale, git
config, layer toggles) and a `mkHost` function that builds a nixos system from `common`
merged with per-host overrides.

the merged result is `settings`, threaded into every module through `specialArgs`. so any
module can read `settings.username`, `settings.nvidia` and so on without importing anything.

## software layers

the stack layers bottom to top, each layer opt in per host:

- base, base system plus sway, audio, bluetooth, file manager, core cli. every host gets this.
- polish, the polished feature complete desktop on top of base.
- dev, dev tools on top of polish.
- gaming, gaming tools and 32-bit GL on top of polish.

`nvidia` is a separate hardware toggle, not a layer. it pulls in the proprietary driver and
sets the wlroots env vars sway needs on that gpu.

the toggles live in `flake.nix` per host:

```nix
desktop = mkHost (common // {
  hostname = "desktop";
  nvidia   = true;
  polish   = true;
  dev      = true;
  gaming   = true;
});
```

`core/modules/toggles.nix` types them as booleans, so a wrong value is a build error.

## module layout

```
core/modules/
  toggles.nix       typed schema for the host.* toggles
  base.nix          always loaded, conditionally imports the rest
  polish.nix        guarded by host.polish
  specialized/
    dev.nix         guarded by host.dev
    gaming.nix      guarded by host.gaming
    nvidia.nix      guarded by host.nvidia
```

host specific config (hardware, drive mounts, monitor layout) lives under `hosts/<host>/`,
not in the modules. the modules stay portable across machines.

## home manager

home manager runs as a nixos module so it rebuilds with the system. each host gets:

- `core/home/base.nix`, shared user config: git, zsh, ssh, sway base, shell companions.
- `core/home/specialized/dev.nix`, dev user tooling (delta, lazygit), gated by the dev toggle.
- `hosts/<host>/home.nix`, per-host overrides: monitor layout, device specific bits.

## the core/ engine and the template

`core/` is the one copy of the engine. the real hosts at the repo root import it, and
`templates.default` points at the same `core/`, so the fork starter and what actually runs
are the same files, nothing to keep in sync:

```bash
nix flake init -t github:EricKrevalis/nixos
```

a fork gets `core/` as its whole repo (its own `flake.nix`, the modules, the home config, a
stub host). my `flake.nix`, `hosts/`, and host-specific `configs/` stay at the root and
never ship.
