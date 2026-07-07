# first build and recovery

notes on the parts the flake does not handle itself: pointing `nixos-rebuild` at this repo on a fresh install, and getting back to a working system if a build breaks.

## how my system finds this repo

the repo lives at `~/.config/nixos`.
i reference it explicitly when i rebuild, no `/etc/nixos` symlink.
the `nrs` / `nrb` aliases (from `home/shell.nix`) expand to:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos
sudo nixos-rebuild boot   --flake ~/.config/nixos
```

with no `#attr` on the flake, nixos-rebuild builds the config matching my hostname, so on `desktop` it builds `nixosConfigurations.desktop`.
the laptop gets the same aliases and resolves to its own name.

i went explicit on purpose.
the old setup symlinked `/etc/nixos/flake.nix` to the repo so a bare `sudo nixos-rebuild switch` would work, but that only works because nixos-rebuild resolves the symlink itself, plain `nix` commands against `/etc/nixos` break on it.
an explicit `--flake` path is unambiguous and works everywhere, and the aliases keep it short.

because there is no `/etc/nixos/flake.nix` anymore, a bare `sudo nixos-rebuild switch` no longer finds the flake.
i always use `nrs` / `nrb` (or the full `--flake` command).

## redoing this on a fresh machine

1. install nixos from the iso, get online.
2. `nix-shell -p git`, then clone the repo to `~/.config/nixos`.
3. generate the hardware config for that machine:
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/.config/nixos/hosts/<host>/hardware-configuration.nix
   ```
4. confirm the hostname matches a config name in `flake.nix` (set by `networking.hostName` in that host's `configuration.nix`).
5. first build, spelled out (the `nrs` alias does not exist until this build activates it):
   ```bash
   sudo nixos-rebuild switch --flake ~/.config/nixos#<host>
   ```
6. reboot. after that `nrs` / `nrb` work from any new shell.

no secrets are defined right now, so a fresh machine comes up complete.
if any exist by then: restore my personal key to `~/.config/sops/age/keys.txt`, add the new host as a recipient (both steps in `docs/secrets.md`), then rebuild.

## if a rebuild breaks things

every switch saves a new generation, so i can always go back.

- at the boot menu, pick an older generation that works.
- from a shell: `sudo nixos-rebuild switch --rollback`.
- list generations: `ls -l /nix/var/nix/profiles/`.
