# todo

the sections below are the real list, each task lives in one with a status:
  [ ] todo   [!] planned   [?] testing   [x] done
TODO and testing at the top just mirror the [!] and [?] items. ideas is the tagged idea pool, done the archive.

refs: https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway
      https://github.com/Alexays/Waybar/wiki/Examples

## TODO:
- [ ] discord (vesktop) screenshare still a bit buggy, wayland screencast portal/pipewire, details in the gaming section.

## testing / work-in-progress:
- [?] stylix live, palette seeded from docs/colors.md, the PROVISIONAL slots (base00/05/06/07/0A/0D) need tuning on the live system. visual pass: foot, fuzzel, mako, zathura, gtk apps, fzf, lazygit, swaylock. waybar, sway, firefox and nvim stay exempt. btop and bat unthemed for now, system packages without home config. decide later: waybar exempt for good or its css colors generated from the palette.
- [?] cfgs/keybinds in current stack (py, sh, lua, md / nvim / sway / plugins)
- [?] typst stack (tinymist + typstyle + browser preview)
- [?] jupyter (jupyterlab in a firefox window, default kernel from nix, opened from nvim)
- [?] language toolchains (rust, c/c++, js/ts, python via the jupyter env) + direnv
- [?] dev buildout, editor and toolchains, the full task list in the dev section
- [?] preview fix landed, typst/md open a dedicated firefox instance, :q closes it, verifying in use

## base:

- [ ] calculator (own app or fuzzel calc mode)

## polish:

- [ ] office suite (libreoffice), docx/xlsx/odt/pptx, also csv/rtf, no handler now
- [ ] email client, wires mailto + .eml/mbox/.vcard, all unhandled now
- [ ] calendar, wires .ics + webcal://, unhandled now
- [ ] pdf annotation and forms (zathura is read-only, okular or similar)
- [ ] image editor (gimp or krita), RAW + .xcf, swayimg only views, no edit
- [ ] password manager: bitwarden, no browser extension, rbw + fuzzel (rofi-rbw/fuzzel-rbw), type via wtype not clipboard, argon2id kdf, vaultwarden self-host long-term
- [ ] torrent client, wires magnet:// + .torrent, unhandled now
- [ ] note taking
- [ ] file sync (syncthing or similar)

## specialized:

### dev:
- [?] previews fixed, typst/md open a dedicated firefox instance (own profile under firefox-previews/), opens with the file, :q closes window and server, nothing left running, super+shift+q clean. verifying in use.
- [ ] lsp + completion foundation: servers from nixpkgs (no mason), calm manual completion, nix/lua/bash/python/markdown
- [ ] nvim colorscheme off the stylix palette, a base16 colorscheme in lazy reading the generated scheme, not its own theme
- [?] typst: treesitter grammar + tinymist server, typstyle format, typst-preview.nvim live browser preview
- [ ] latex: treesitter grammar + texlab server + vimtex for build and forward/inverse pdf search
- [?] jupyter notebooks: jupyterlab in a firefox window, opened from nvim. molten/sixel dropped, too fragile on foot/nvidia
- [?] per-project dev environments: direnv + nix-direnv wired, learn flake devShells next, lsp servers from the project shell
- [ ] compare devenv vs plain devShells: devenv adds services/presets but its own cli steps outside flakes, reach for it when a project needs services, not by default
- [ ] revisit python lsp: on basedpyright + ruff now, re-evaluate pyrefly (1.0) and ty (still beta) once they harden
- [ ] docker or podman
- [?] language toolchains: rust, c/c++, js/ts global for scratch use, python rides the jupyter env, projects pin their own via devShells
- [ ] research the top employable languages more before adding toolchains, current landscape read: python, js/ts, java, c#, c/c++, go, sql, rust
- [ ] learning track, cover languages worth learning for hire, not just ones already written. settled set: typescript, go, sql on postgres. skip java (known, disliked) and c# for now
- [ ] typescript: tsc global, typescript-language-server + prettier, ts/tsx grammar. formatter choice prettier over biome, verify attrs
- [ ] go: go toolchain global (gofmt and gopls builtin), gopls lsp, goimports format, go grammar
- [ ] sql/postgres: postgres engine (always-on local service vs per-project devShell tbd), sqls lsp over postgres-lsp, sqlfluff format on the postgres dialect, sql grammar
- [ ] ultra lategame: pi harness, ponytail/caveman, maybe open LLM, huge optimizations

### nvim, to explore later:
- [ ] gitsigns: git gutter signs, stage/reset/navigate hunks, inline blame, complements lazygit's commit view
- [ ] mini.surround: add/change/delete the pair around text, manual so not aggressive
- [ ] treesitter-textobjects: function/class/argument motions, source matched from nix like the grammars
- [ ] telescope-ui-select: route lsp pickers like code actions through telescope, not a bare list
- [ ] fidget: lsp progress spinner
- [ ] trouble: project-wide diagnostics panel
- [ ] luasnip + friendly-snippets: snippet library, blink's builtin covers the basics for now
- [ ] render-markdown: in-buffer markdown rendering
- [ ] docs/nvim.md: write up the dev-layer decisions (treesitter from nix, blink lua matcher, basedpyright + ruff, format on demand)

### gaming:
- [ ] steam rebuilds its shader cache every reboot, re-validates and re-processes vulkan shaders on boot, investigate the cache setup
- [ ] performance pass for the box (cpu, ram, gpu), research what's worth tuning for gaming
- [ ] discord (vesktop) screenshare still a bit buggy, likely a wayland screencast portal/pipewire issue, investigate
- base stack complete (steam + GE-Proton, gamescope, gamemode, vesktop, mangohud), see done

### nvidia:
- [ ] fan/clock control on wayland, nvidia-settings is useless there (needs Xorg), LACT is the lead candidate, research in depth

## hardware / system:

- [ ] udev rules for the input and audio peripherals
- [ ] usb dac control

## maintenance:

cleanup nix doesn't handle on its own.
- [ ] sweep stray dotdirs and ~/.cache bloat that builds up over time
- [ ] decide if a short cleanup guide is worth writing, deeper gc than nix gc (journal, ~/.cache, old downloads)

## audio:

- [ ] test routing between both devices (mic interface and usb dac)

## home-manager:

- [ ] neovim config
- [ ] remaining ssh work (tunnel/jump hosts, per secrets.md). remote resilience: tmux for session persistence, mosh on top only for flaky/roaming links (needs a udp port open), pair mosh with tmux not zellij.

## secrets:

- [ ] add the surface host key as a recipient in .sops.yaml once that machine exists, then run sops updatekeys on secrets/*

## repo:

- [ ] surface host: generate hardware config and re-enable in flake.nix

## ideas:

not committed. pull one up into a section above when it's worth doing.

### desktop
- [ ] removable drive tray icon/applet, so usb sticks can be ejected safely without a terminal
- [ ] per-app window rules: workspace assigns, scratchpad terminal
- [ ] window resize/move binds, a dedicated resize mode
- [ ] thunar thumbnails: ffmpegthumbnailer for video, poppler for pdf
- [ ] gtk + qt theming for one consistent look, mismatched now
- [ ] kanshi hotplug profiles, auto-apply the layout on monitor connect (laptop win)
- [ ] volume/brightness osd, only the wiremix tui now
- [ ] keybind cheatsheet overlay
- [ ] caps lock remap, pointer accel/scroll settings
- [ ] emoji picker on a keybind
- [ ] mako do-not-disturb toggle for games and calls
- [ ] per-monitor wallpapers or rotation
- [ ] font rendering knobs (hinting, subpixel)
- [ ] force or auto dark mode across gtk apps
- [ ] gammastep tray icon (gammastep-indicator), same schedule. trying `tray = true` now, verify the indicator and the fixed-time service coexist, roll back if the applet wants to own scheduling.
- [ ] cliphist size limit or clear on boot
- [ ] clipboard-only screenshot grab, separate from satty
- [ ] scratch note / quick-capture keybind
- [ ] screen recording (wf-recorder or obs)

### shell + tools
- [ ] eza (ls), tealdeer (tldr), dust + duf, sd, yq, glow
- [ ] jq, still not installed
- [ ] yazi tui file manager
- [ ] atuin shell history, decide deliberately
- [ ] nh + nix-output-monitor for nicer rebuilds
- [ ] nix-tree and nix-index for closure and package spelunking
- [ ] comma, run any nixpkgs program without installing
- [ ] tmux or zellij
- [ ] git commit signing + a global gitignore

### system
- [ ] fstrim for ssd health
- [ ] swap: zram or a real partition, none now
- [ ] earlyoom or systemd-oomd so memory load can't hard-lock the box
- [ ] firewall, confirm what's open
- [ ] systemd-boot configurationLimit so the boot menu stops growing
- [ ] scheduled backups (restic or borg), nothing protected now
- [ ] dns hardening (systemd-resolved, optional doh)
- [ ] vpn (tailscale or wireguard)
- [ ] btrfs/zfs snapshots if the filesystem supports it
- [ ] printing + scanning if the need ever comes up
- [ ] monitor color/icc profiles
- [ ] apparmor, secure boot (lanzaboote), tighter polkit rules
- [ ] ntp/clock format
- [ ] disable the pc speaker beep
- [ ] hdr, parked, not really there on sway yet

## done:

- [x] lsp root_dir falls back to the file's dir, servers attach on loose files not just git repos
- [x] oil q quits back to the previous buffer
- [x] telescope pickers, oil, window splits/buffers, system clipboard both ways, persistent undo verified
- [x] lsp attaches for lua, nix, bash, markdown (python verified)
- [x] blink completion: passive popup, Ctrl-y accepts, enter stays a newline, self. lists lsp items
- [x] conform <leader>cf formats nix/lua/python/bash (after nrs pulls the formatter binaries)
- [x] lualine statusline appears after restart
- [x] <leader>e diagnostic float, and treesitter folds (zM zR za)
- [x] custom autotiler (configs/autotile) replaces autotiling-rs, splits from live window geometry not just on focus. resize fires no ipc event, self-corrects on next focus/move
- [x] power menu (fuzzel --dmenu, own config), fires lock/suspend/reboot/shutdown from Mod+Shift+e, the waybar button and the fuzzel entry
- [x] foot replaced alacritty: shift+enter newline in claude, popups float, "open terminal here", no middle-click paste, Ctrl+Shift+R scrollback search
- [x] float dialogs via sway's built-in auto-float, no explicit for_window rule needed
- [x] screen lock (swaylock + swayidle), unlocks and locks before sleep
- [x] xdg-user-dirs recreate on build
- [x] nvidia suspend/resume clean with powerManagement on, tested under load
- [x] layer restructure: leaner base, fzf/fd/bat to dev, mullvad/btop/cliphist to polish, steam rule to gaming, nvidia launch quirks to nvidia.nix
- [x] file type handling tested (md, txt, pdf, images, audio, video)
- [x] firefox prefs in-repo, not hand-pasted into the profile
- [x] firefox extensions via profile (uBlock + theme), not enterprise policy
- [x] thunar open-with read-only fixed (mimeapps.list unmanaged, x-zerosize files pinned to nvim)
- [x] copy/paste: Ctrl+C/V in gui apps, Ctrl+Shift+C/V in the terminal; Shift+Enter newline in prompts
- [x] primary/middle-click clipboard retired, both copy and paste
- [x] images in cliphist
- [x] cpu microcode managed (amd, 0xa201030)
- [x] old flatpak + broken firefox state cleaned; profile in ~/.config/mozilla, arkenfox SUCCESS
- [x] pipewire sample rate + allowed rates (44.1k/48k) + resample quality
- [x] wireplumber mic chain (mic interface only) and dac output (usb dac prioritized)
- [x] mic settings versioned in configs
- [x] mic interface utility daemon enabled
- [x] shell stack: starship, zoxide (cd), fzf, autosuggestion, syntax highlighting; delta + lazygit on the dev layer
- [x] gaming stack: steam + GE-Proton, gamescope, gamemode, vesktop, mangohud, vm.max_map_count bump
- [x] nvidia stable + open kernel modules, validated under load (thermals, suspend/resume, explicit-sync)
- [x] hardware cursors retested under fullscreen xwayland, WLR_NO_HARDWARE_CURSORS stays removed
