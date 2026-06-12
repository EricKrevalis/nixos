# nixos-config

My NixOS setup for `desktop` (and later `laptop`). Flake-based, with Home Manager
running as a NixOS module.

## Rebuilding

```bash
sudo nixos-rebuild switch
```

This uses the flake through the `/etc/nixos/flake.nix` symlink and picks the config
matching my hostname. See `docs/bootstrap.md` for how that link is set up and how to
recreate it on a fresh install.

## Layout

```
flake.nix / flake.lock   inputs (nixos-unstable + home-manager) and the host configs
hosts/<host>/            per-machine: configuration.nix + hardware-configuration.nix
home/home.nix            Home Manager (git, zsh, ...)
modules/                 shared/reusable Nix modules
docs/                    my own notes (not read by Nix)
configs/                 raw config files, wired in from home.nix (see below)
scripts/                 shell scripts, packaged through Nix (see below)
```

`configs/` and `scripts/` only get created when there's a real file for them.

## Conventions

Anything that should change the system goes through Nix, so the file in the repo is
the one that's actually live. No hand-editing the running copy.

- Config files: keep the real file in `configs/`, point at it from `home.nix`:
  ```nix
  xdg.configFile."waybar/config".source = ./configs/waybar/config;
  ```
- Scripts: keep them in `scripts/`, package them so they land on PATH:
  ```nix
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "name" (builtins.readFile ./scripts/name.sh))
  ];
  ```
- `docs/` is just notes for me. Nothing in there affects the build.

Bigger research docs (stack, ledger, runbook, ssh) live on the work drive, not here.
