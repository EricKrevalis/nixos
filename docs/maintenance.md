# maintenance

## checks after a rebuild

after any `nrs` or `nrb`:

- sway started, waybar visible with clock and tray
- `Mod+Enter` opens foot
- `Mod+d` opens fuzzel
- audio: open wiremix, both devices visible, playback works
- neovim: open a .nix file, LSP attaches (`:LspInfo`), blink popup appears
- firefox opens, arkenfox active (`about:config`, search `arkenfox`)
- bluetooth connects to the speaker
- screenshot: `Mod+Shift+s`, select a region, satty opens
- cliphist: `Mod+c` shows history
- goxlr-utility daemon running: `systemctl --user status goxlr-utility`
- gaming when relevant: steam opens, gamemode active under a game

## updating

four inputs in the flake: nixpkgs, home-manager, sops-nix, stylix.
the last three follow nixpkgs, so updating nixpkgs pulls everything forward together.

update all inputs:

```
cd ~/.config/nixos
nix flake update
nrs
```

update one input:

```
nix flake update nixpkgs
```

watch after an update:

- nvidia driver: `nvidiaPackages.latest` follows the latest branch on its own.
  stable is commented as a fallback right below the latest line in `modules/optional/nvidia.nix`.
  check that file if sway breaks or the gpu probe regresses.
- kernel: on LTS. a kernel bump can clash with the nvidia open modules.
  if sway fails to start, check `journalctl -b` before blaming the driver.
- home-manager: follows nixpkgs, always matches. a major release can rename options.
  scan `nrs` output for deprecation warnings.
- stylix: palette is provisional, an update could shift theming on opted-in apps.
  `docs/colors.md` tracks what's provisional.

sops-nix updates freely, no secrets defined.

after any update run the checks above.

## clearing old generations and garbage

nix gc runs weekly, 30-day retention, set in `modules/nix.nix`.
to force it now or go deeper.

delete all old system generations and collect garbage:

```
sudo nix-collect-garbage -d
```

delete generations older than N days instead of all:

```
sudo nix-collect-garbage --delete-older-than 30d
```

home-manager keeps its own generation list:

```
home-manager generations           # list them
home-manager remove-generations <id> <id> ...
nix-collect-garbage                # collect after removing
```

store size before and after:

```
du -sh /nix/store
```

`nix store gc` collects garbage without touching generations.
`nix-collect-garbage -d` removes generations first, then collects.
do the generation sweep first to actually free space.

## improving the build

`docs/todo.md` is the source of truth.
active sections: dev, nvim, gaming, nvidia, polish.
pick a task, research it, then implement through nix so the repo stays the live config.

for a change:

1. edit the file in `~/.config/nixos`
2. `nrs` to apply
3. test
4. commit once it works
