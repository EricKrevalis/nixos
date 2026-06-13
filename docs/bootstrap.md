# bootstrap and recovery

notes on the one part the flake does not handle itself: the link that makes `nixos-rebuild`
use this repo. i redo this by hand on a fresh install.

## how my system finds this repo

when i run `sudo nixos-rebuild switch` with no flags:

1. it reads `/etc/nixos/flake.nix`, which i symlinked to `~/nixos-config/flake.nix`, so it
   picks up this repo's flake.
2. it builds the config matching my hostname. mine is `desktop`, so it builds
   `nixosConfigurations.desktop`.

the symlink just drops a `flake.nix` where the command already looks, while the real file
stays here under git. that is why the plain command works and the config is still version
controlled.

`/etc/nixos/` only holds that symlink now. the install also left a `configuration.nix` and
`hardware-configuration.nix` there, but the flake reads `hosts/desktop/` instead, so those
were dead weight. i deleted them.

## the symlink i made

```bash
sudo ln -sfn ~/nixos-config/flake.nix /etc/nixos/flake.nix
ls -l /etc/nixos/flake.nix   # shows the -> arrow
```

without it i would run `sudo nixos-rebuild switch --flake ~/nixos-config#desktop` every
time. the symlink just makes the short command work.

## redoing this on a fresh machine

1. install nixos from the iso, get online.
2. `nix-shell -p git`, then clone the repo to `~/nixos-config`.
3. generate the hardware config for that machine:
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/<host>/hardware-configuration.nix
   ```
4. confirm the hostname matches a config name in `flake.nix` (set by `networking.hostName`
   in that host's `configuration.nix`).
5. make the symlink (above).
6. first build, spelled out:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#<host>
   ```
7. reboot. after that the short `sudo nixos-rebuild switch` works.

until the secrets are wired the machine builds fine but comes up without my private bits
(monitor layout, audio drop-ins, work ssh identity), they stay encrypted. to fix, after the
first build restore my personal key to `~/.config/sops/age/keys.txt` and add the new host as
a recipient, both steps are in `docs/secrets.md`. then rebuild.

## if a rebuild breaks things

every switch saves a new generation, so i can always go back.

- at the boot menu, pick an older generation that works.
- from a shell: `sudo nixos-rebuild switch --rollback`.
- list generations: `ls -l /nix/var/nix/profiles/`.
