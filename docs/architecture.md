# architecture

## the flake

`flake.nix` holds a `common` attrset shared by every host (username, timezone, locale, git config, toggles) and a `mkHost` function that builds a nixos system from `common` merged with per-host overrides.

the merged result is `settings`, passed to every module through `specialArgs`.
so any module can read `settings.username`, `settings.nvidia` and so on without importing anything.

## no layers

the old base/polish/dev layers are gone.
the system is built to work as one piece, so it ships as one piece: everything shared is always on.
only what genuinely splits off cleanly is a toggle, hardware (`nvidia`) and machine roles (`gaming`, `work`, `arkenfox`).

the toggles live in `flake.nix` per host:

```nix
desktop = mkHost (common // {
  hostname = "desktop";
  nvidia   = true;
  gaming   = true;
  work     = true;
  arkenfox = true;
});
```

each optional module gates itself with `lib.mkIf settings.<toggle>`, system and home side alike.
a misspelled toggle is a missing attribute, so it fails at eval, never silently.

## module layout

```
modules/            system side, one file per domain
  default.nix       entry, imports everything
  boot/network/locale/desktop/audio/storage/fonts/stylix/packages/users/nix .nix
  optional/         gaming.nix, nvidia.nix, work.nix, guarded by their toggle
home/               home manager side, one file per program
  default.nix       entry, imports everything
  theme/shell/ssh/git/foot/fuzzel/sway/... .nix
  optional/         gaming.nix, arkenfox.nix, guarded by their toggle
```

the unit rule: home splits per program (one file answers "how is X configured"), modules per domain (system options rarely belong to one program and only make sense jointly, the session launch spans getty, sway, pam and portals in `desktop.nix`).

host specific config (hardware, drive mounts, monitor layout) lives under `hosts/<host>/`, not in the modules.
the modules stay portable across machines.

## home manager

home manager runs as a nixos module so it rebuilds with the system. each host gets:

- `home/`, the shared user config, every program its own file.
- `hosts/<host>/home.nix`, per-host overrides: monitor layout, device specific bits.

## the template

`templates.default` points at the whole repo, so the fork starter and what actually runs are the same files, nothing to keep in sync:

```bash
nix flake init -t github:EricKrevalis/nixos
```

a fork copies everything, deletes `hosts/desktop` and `hosts/surface`, and starts from the commented `nixos` host entry with the empty `hosts/nixos` host.
