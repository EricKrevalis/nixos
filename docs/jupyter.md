# jupyter

basics for now, more later.

## what's set up

all in `home/jupyter.nix`:

- `jupyterEnv`: python with jupyterlab, ipykernel, numpy, pandas, matplotlib, on PATH. the lab binaries are re-wrapped there to fix a nixpkgs bug (#423927) that stopped lab from starting.
- a default kernel, `python3 (default)`.
- `jlab`: a small script that runs lab headless and opens it in a throwaway firefox window off the main profile. closing that window shuts the server down, so nothing lingers. takes an optional notebook path.
- the theme and code font are preset: dark, atkynson.

## running it

`jlab` from anywhere opens a private firefox window and leaves the terminal free. `jlab notebook.ipynb` opens straight to that file. opening a `.ipynb` in nvim runs the same thing.

closing the window kills the server. lab autosaves every 120s and firefox warns before closing an unsaved notebook, so at worst a couple minutes of edits are at risk, and the file is never corrupted.

## adding kernels

the default env stays small, extra kernels go per project. both ways below show up in lab's launcher next to the default:

- quick: make a venv, `pip install ipykernel` plus any libs, then `python -m ipykernel install --user --name proj --display-name "proj"`. it lands in `~/.local/share/jupyter/kernels/`.
- reproducible: a per-project devShell. direnv is already set up, so the project brings its own python, loads on `cd`, and registers its ipykernel the same way. this is the one for real projects.

for a kernel available everywhere, add another env and kernel.json next to the default.

## theme and font size

the theme and code font are in the `apputils-extension/themes` setting, written by home-manager. the keys are `code-font-family` and `code-font-size`. it's read-only, so to change the size, edit the px in jupyter.nix and rebuild, not the gui. downside: this one setting can't be changed in the gui, everything else still can.

font size is 14px, change it there and rebuild.

## opening files from nvim

`configs/nvim/lua/config/openexternal.lua`. files that aren't for editing open in their app instead, and the empty buffer is dropped:

- `.ipynb` opens in `jlab`.
- pdf, images, video, audio open via `xdg-open`, which routes to swayimg, zathura, mpv.

typst preview starts on its own when a `.typ` file opens, in a private firefox window. it updates live, no saving needed. that's in `lua/plugins/typst-preview.lua`.

markdown has no in-buffer renderer, treesitter highlights the source. `:MarkdownPreview` opens a full render in a private firefox window, `:MarkdownPreviewStop` closes it. that's `markdown-preview.nvim`.
