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

## not colors (so they don't get grepped in by mistake)

- modules/optional/gaming.nix: `nixpkgs#351516` is a github issue reference.
- home/optional/gaming.nix: mangohud `background_alpha = 0.25` is opacity.
- mako (home/mako.nix) sets only `border-radius`, no colors yet, it still uses mako's default palette.
- foot sets no colors yet, left for stylix.
