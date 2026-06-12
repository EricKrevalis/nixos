# Bootstrap & recovery

Notes on the one part that isn't handled by the flake itself: the link that makes
`nixos-rebuild` use this repo. I have to redo this by hand on a fresh install.

## How my system finds this repo

When I run `sudo nixos-rebuild switch` with no flags:

1. It reads `/etc/nixos/flake.nix`, which I symlinked to `~/nixos-config/flake.nix`.
   So it picks up this repo's flake.
2. It builds the config matching my hostname. My hostname is `desktop`, so it
   builds `nixosConfigurations.desktop`.

The symlink just puts a `flake.nix` where the command already looks, while the real
file stays here in the repo under git. That's why the plain command works and the
config is still version-controlled.

`/etc/nixos/` only holds that symlink now. The install also left a
`configuration.nix` and `hardware-configuration.nix` there, but the flake reads
`hosts/desktop/` instead, so those were dead weight. I deleted them.

## The symlink I made

```bash
sudo ln -sfn ~/nixos-config/flake.nix /etc/nixos/flake.nix
ls -l /etc/nixos/flake.nix   # shows the -> arrow
```

Without it I'd have to run `sudo nixos-rebuild switch --flake ~/nixos-config#desktop`
every time. The symlink is just so the short command works.

## Redoing this on a fresh machine

1. Install NixOS from the ISO, get online.
2. `nix-shell -p git`, then clone the repo to `~/nixos-config`.
3. Generate the hardware config for that machine:
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/<host>/hardware-configuration.nix
   ```
4. Confirm the hostname matches a config name in `flake.nix` (set by
   `networking.hostName` in that host's `configuration.nix`).
5. Make the symlink (above).
6. First build, spelled out:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#<host>
   ```
7. Reboot. After that the short `sudo nixos-rebuild switch` works.

## If a rebuild breaks things

Every switch saves a new generation, so I can always go back.

- At the boot menu, pick an older generation that works.
- From a shell: `sudo nixos-rebuild switch --rollback`.
- List generations: `ls -l /nix/var/nix/profiles/`.
