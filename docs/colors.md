# colors

every color the config sets by hand, what it does, and exactly where it lives. written before moving theming to stylix so the hand-tuned work isn't lost: stylix drives everything from one base16 palette, this is the record of what i had so i can rebuild it as overrides or seed the palette from it.

the palette now lives in modules/stylix.nix as the stylix base16 scheme, seeded from the table below.
this file stays as the record of the original hand-tuned values.

the look is a warm forest scheme, not one tight palette: forest green plus burnt orange plus brown, dark backgrounds. the accent shifts per surface (sway borders brown, waybar accent orange, starship green/orange), so a base16 mapping has to spread these across the accent slots rather than collapse them to one.

## palette

| hex | rough name | where |
| --- | --- | --- |
| #6A5535 | brown | sway focused border |
| #3A2210 | dark brown | sway unfocused border |
| #cc3333 | red | sway urgent border |
| #ffffff | white | sway focused/urgent text |
| #888888 | grey | sway unfocused text |
| #d4783a | orange | waybar primary accent (text, clock, focused workspace, connectivity icons) |
| #AA6A42 | brown-orange | waybar workspace hover text |
| #7d9470 | sage | waybar pill border, hover background |
| #a8b898 | pale green | waybar idle workspace dots |
| #6b8a62 | muted green | waybar persistent workspace dots |
| #9aaa88 | grey-green | waybar muted/disconnected icons |
| #0f2910 | dark green | waybar pill background (at 80%) |
| #346b30 | forest green | starship prompt, success |
| #bc4e20 | burnt orange | starship prompt, error |
| #585858 #6b6b6b #999999 | lifted greys | computer icon overlay |

## sway window borders

home/sway.nix, the `colors` block. focused windows get the brown, everything dim gets the dark brown, urgent gets red. text is white on the active surfaces, grey on the dim ones.

```nix
colors = {
  focused = {
    border = "#6A5535"; background = "#6A5535"; text = "#ffffff";
    indicator = "#6A5535"; childBorder = "#6A5535";
  };
  unfocused = {
    border = "#3A2210"; background = "#3A2210"; text = "#888888";
    indicator = "#3A2210"; childBorder = "#3A2210";
  };
  focusedInactive = { # same as unfocused
    border = "#3A2210"; background = "#3A2210"; text = "#888888";
    indicator = "#3A2210"; childBorder = "#3A2210";
  };
  urgent = {
    border = "#cc3333"; background = "#cc3333"; text = "#ffffff";
    indicator = "#cc3333"; childBorder = "#cc3333";
  };
};
```

## waybar

configs/waybar/style.css. transparent bar, each module a rounded pill: dark green translucent fill, sage border. orange is the running accent (default text, clock, focused workspace, the audio/bt/net icons), greens carry the workspace states, grey-green marks muted or disconnected.

- bar text default: `color: #d4783a` (line 11)
- pill background: `background: rgba(15, 41, 16, 0.8)` (#0f2910 at 80%, line 19)
- pill border: `border: 1px solid #7d9470` (line 20)
- clock text: `color: #d4783a` (line 28)
- workspace dot idle: `color: #a8b898` (line 35)
- workspace dot focused: `color: #d4783a` (line 41)
- workspace dot persistent: `color: #6b8a62` (line 47)
- workspace hover background: `background: rgba(125, 148, 112, 0.35)` (#7d9470 at 35%, line 52)
- workspace hover text: `color: #AA6A42` (line 54)
- audio/bluetooth/network icons: `color: #d4783a` (line 72)
- muted/disconnected icons: `color: #9aaa88` (lines 76, 81)

## starship prompt

home/shell.nix, the starship `character` settings. the » arrow turns forest green after a command succeeds, burnt orange after one fails.

```nix
character = {
  success_symbol = "[»](#346b30)";
  error_symbol = "[»](#bc4e20)";
};
```

typst module gets its own accent, unrelated to the forest scheme: `typst.style = "#0093A7"` (teal, typst's own brand color).

## computer icon overlay

home/theme.nix, the inline `computer.svg`. papirus-dark reuses its light computer glyph, too dark on this desktop, so i lifted three greys to make it read. greys, not part of the accent scheme, but a deliberate edit.

- body `#333333` -> `#585858`
- edge `#595959` -> `#6b6b6b`
- screen `#8e8e8e` -> `#999999`
- plus white highlights at 0.1 / 0.2 opacity

## firefox theme

home/optional/arkenfox.nix. a sideloaded amo theme, "natural forest green" 1.0, not a hex set i control. the colors live inside the xpi, listed here so the green firefox chrome isn't forgotten when matching the rest.

## swaylock

home/swaylock.nix, `programs.swaylock.settings`. only the background is set, `color = "0f2910"` (the same dark green as the waybar pill, no leading #). the indicator ring keeps swaylock's defaults for now, radius 90 and thickness 8 are sizes not colors.

## fuzzel, main launcher and power menu

home/fuzzel.nix. both the main launcher's `settings.colors` and the `powermenu` script's embedded fuzzel config
hardcode the same palette, `lib.mkForce` on the main launcher since stylix's fuzzel target sets its own colors first.
dark brown background `2a1c0e` at ~95%, muted text `9a8f80`, the orange accent `d4783a` on matches,
the sway focus brown `6a5535` on the selection and border, white selection text.

## live base16 scheme, pre-bundle snapshot

modules/stylix.nix, the full 16 slots as hand-set before switching to a bundled base16 scheme.
kept here so the hand-tuned forest palette isn't lost once a bundle takes over base16Scheme.

| slot | hex | role |
| --- | --- | --- |
| base00 | 16120b | background |
| base01 | 2a1c0e | lighter background |
| base02 | 3a2210 | selection, dark brown |
| base03 | 6a5535 | comments, brown |
| base04 | 9a8f80 | dim foreground |
| base05 | d8cfc0 | foreground |
| base06 | e8e2d5 | light foreground |
| base07 | f5f1e8 | lightest |
| base08 | cc3333 | red |
| base09 | d4783a | orange accent |
| base0A | c9a554 | yellow |
| base0B | 6b8a62 | green |
| base0C | 7d9470 | cyan slot, sage |
| base0D | 8a9bab | blue slot, grey blue |
| base0E | aa6a42 | magenta slot, brown orange |
| base0F | bc4e20 | burnt orange |

## stylix sweep, dropping hand-tuned overrides

modules/stylix.nix now points base16Scheme at a pkgs.base16-schemes bundle (gruvbox-material-dark-hard) instead of the inline hexes above.
the apps hand-tuned around the old forest hexes now follow stylix's own targets, so they track whatever bundle is set instead of staying pinned to forest.

changes:

- home/sway.nix: drop `stylix.targets.sway.enable = false` and the hand-tuned `colors` block, stylix themes the borders.
- home/fuzzel.nix, main launcher: drop the `lib.mkForce` `settings.colors` block, stylix's fuzzel target colors it with its own role mapping (base00 background, base05 text, base0A match, base02 selection, base0D border).
- home/fuzzel.nix, powermenu script: its ini is a separate `pkgs.writeText` config, not the `programs.fuzzel` module, the stylix target never reaches it. interpolated instead from `config.lib.stylix.colors`, same role mapping as the main launcher, both stay in sync without hand-picked hex. opacity suffix on the background (f2, ~95%) stays a static cosmetic choice, not a color. the main launcher's background follows `stylix.opacity.popups` instead, fully opaque at the default 1.0, so the two differ slightly there.
- configs/waybar/style.css: hand-tuned hex backed up unchanged to configs/waybar/archive/style-hand-tuned-forest.css. the live stylesheet moves into home/waybar.nix as an interpolated string, colors read from `config.lib.stylix.colors.withHashtag`, same pill/tab layout kept. role mapping carries over the old slot choices from the pre-bundle snapshot above, those slots were originally picked to match: base09 (bar text, clock, custom-module icons, focused workspace dot), base0C (pill border, hover background), base0B (persistent workspace dot), base0E (workspace hover text), base04 (idle workspace dot, muted/disconnected icons), base01 (pill background, at 80%).
  stylix's own waybar target isn't used here: it hooks into the `programs.waybar` home-manager module, this config writes `config.jsonc`/`style.css` straight to `xdg.configFile`, the target has nothing to attach to.
- home/nvim.nix: the neovim target stays off, it only writes into the unused `programs.neovim` wrapper. the palette gets there anyway: home/nvim.nix exports the 16 hexes as a lua data file under xdg data, configs/nvim/lua/plugins/colorscheme.lua reads it and hands it to base16-nvim, the same setup() call the stylix target would have made.

staying hand-tuned, not part of this sweep:

- home/optional/gaming.nix, mangohud: `stylix.targets.mangohud.enable = false` stays. the overlay's alpha (0.35 / 0.25) is tuned for low visibility on purpose, and the stylix target would force its own opacity along with color, not just recolor it.
- home/optional/arkenfox.nix, firefox: color target stays off. the sideloaded "natural forest green" theme is a real firefox extension with its own palette, turning the target on would just fight it.

## not colors (so they don't get grepped in by mistake)

- modules/optional/gaming.nix: `nixpkgs#351516` is a github issue reference.
- home/optional/gaming.nix: mangohud `background_alpha = 0.25` is opacity.
- mako (home/mako.nix) sets only `border-radius`, its colors come from stylix's mako target.
- foot (home/foot.nix) sets no colors, they come from stylix's foot target.
