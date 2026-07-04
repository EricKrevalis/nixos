{ config, settings, lib, pkgs, ... }:

let
  # jupyterlab, its default kernel, and the analysis libs. replaces a per-notebook venv
  jupyterEnv =
    let
      py = pkgs.python3.withPackages (ps: with ps; [
        jupyterlab
        ipykernel
        numpy
        pandas
        matplotlib
      ]);
      lab = pkgs.python3Packages.jupyterlab;
    in
    # nixpkgs jupyterlab wraps its bins with a literal unexpanded JUPYTERLAB_DIR='$out/...' (nixpkgs#423927).
    # it resolves against cwd, so the lab assets go missing and lab refuses to start.
    # the export is unconditional, no session var or --app-dir survives it.
    # re-wrap the three lab bins onto the real entry with the correct dir, avoids a source rebuild.
    pkgs.symlinkJoin {
      name = "jupyter-env";
      paths = [ py ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for b in jupyter-lab jupyter-labextension jupyter-labhub; do
          rm -f $out/bin/$b
          makeWrapper ${lab}/bin/.$b-wrapped $out/bin/$b \
            --set JUPYTERLAB_DIR ${lab}/share/jupyter/lab \
            --prefix PATH : ${py}/bin
        done
      '';
    };

  # run lab headless and open it in a throwaway firefox window, off the main profile.
  # closing that window shuts the server down, so a forgotten server can't linger.
  # optional arg: a notebook to open straight away. leaves the terminal free
  jlab = pkgs.writeShellScriptBin "jlab" ''
    set -uo pipefail

    # re-exec detached in a new session so the terminal is freed and Ctrl-C or closing it can't reach the server.
    # the copy below does the real work
    if [ "''${JLAB_BG:-}" != 1 ]; then
      JLAB_BG=1 setsid "$0" "$@" >/dev/null 2>&1 </dev/null &
      exit 0
    fi

    log=$(mktemp)
    profile="''${XDG_DATA_HOME:-$HOME/.local/share}/jlab/firefox"
    mkdir -p "$profile"

    target="/lab"
    if [ -n "''${1:-}" ]; then
      cd "$(dirname "$1")" || exit 1
      target="/lab/tree/$(basename "$1")"
    fi

    ${jupyterEnv}/bin/jupyter lab --no-browser >"$log" 2>&1 &
    server=$!

    url=""
    for _ in $(seq 1 100); do
      url=$(grep -om1 'http://localhost:[0-9]*/lab?token=[A-Za-z0-9]*' "$log") && [ -n "$url" ] && break
      kill -0 "$server" 2>/dev/null || break
      sleep 0.1
    done
    if [ -z "$url" ]; then
      echo "jupyter lab did not start:" >&2; cat "$log" >&2
      kill "$server" 2>/dev/null; rm -f "$log"; exit 1
    fi

    port=$(echo "$url" | sed -n 's#.*localhost:\([0-9]*\)/.*#\1#p')
    token=''${url##*token=}
    # dedicated instance so closing the window exits firefox, the script waits on it
    firefox --no-remote --profile "$profile" --private-window \
      "http://localhost:$port$target?token=$token" >/dev/null 2>&1 || true

    kill "$server" 2>/dev/null || true
    wait "$server" 2>/dev/null || true
    rm -f "$log"
  '';
in

# home-side dev tooling, gated like core/modules/specialized/dev.nix.
lib.mkIf settings.dev {

  # claude-code fullscreen (alternate-screen) renderer, the declarative equivalent of /tui fullscreen
  home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";

  # default kernel, discovered through this spec
  xdg.dataFile."jupyter/kernels/python3/kernel.json".text = builtins.toJSON {
    argv = [ "${jupyterEnv}/bin/python3" "-m" "ipykernel_launcher" "-f" "{connection_file}" ];
    display_name = "python3 (default)";
    language = "python";
  };

  # lab ui seeded declaratively: dark theme, atkynson everywhere.
  # the three sizes are the knobs, change them here and rebuild.
  # read-only symlink, so this plugin's settings can't be changed from the gui, other plugins stay writable.
  home.file.".jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings".text =
    let font = "AtkynsonMono Nerd Font Mono";
    in builtins.toJSON {
      theme = "JupyterLab Dark";
      overrides = {
        "code-font-family" = font;     # cell editors
        "code-font-size" = "16px";
        "content-font-family" = font;  # rendered markdown and text output
        "content-font-size1" = "14px";
        "ui-font-family" = font;       # menus, sidebar, tabs
        "ui-font-size1" = "12px";
      };
    };

  # no warnings on loose files without a compile db, -Wall covers the useful ones
  xdg.configFile."clangd/config.yaml".text = ''
    CompileFlags:
      Add:
        - -Wall
        # - -Wextra  # unused params, sign-compare, noisier. per-project if wanted
  '';

  # out-of-store symlink to the live repo, lua edits are instant, lazy writes lazy-lock.json back. neovim from base
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/nixos/core/configs/nvim";

  # treesitter grammars and queries for neovim, both from one nvim-treesitter package.
  # mismatched sources let a query reference a node the parser lacks (the except* skew).
  # no compiler here, grammars are prebuilt; symlinkJoin merges the per-lang .so into one dir.
  xdg.dataFile."nvim/treesitter/parser".source =
    "${pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        # edited languages
        nix
        lua
        bash
        python
        markdown
        markdown_inline # markdown is two grammars, this one does inline marks and fenced code
        typst
        rust
        c
        cpp
        javascript
        typescript
        # support grammars
        vimdoc # colors neovim :help pages
        query # colors treesitter .scm files
        json
        toml
        yaml
      ];
    }}/parser";

  # the matching queries, from the same package as the grammars above.
  xdg.dataFile."nvim/treesitter/queries".source =
    "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";

  # markdown-preview.nvim, its node app prebuilt.
  # lazy loads it from here by path, skipping the plugin's own download, a dynamically linked binary that won't run on nixos.
  # node is declared in home.packages below for the preview server.
  xdg.dataFile."nvim/mkdp".source = pkgs.vimPlugins.markdown-preview-nvim;

  # tooling for neovim, binaries only, the lua wiring is in the nvim config.
  home.packages = with pkgs; [
    # language servers
    nixd                 # nix
    lua-language-server  # lua
    bash-language-server # bash
    basedpyright         # python types, completion, navigation
    ruff                 # python lint and format
    marksman             # markdown
    tinymist             # typst, also backs the live preview
    rust-analyzer        # rust
    clang-tools          # c/c++, clangd + clang-format
    typescript-language-server # js/ts
    # formatters
    nixfmt               # nix, official rfc style
    stylua               # lua
    shfmt                # bash
    typstyle             # typst
    rustfmt              # rust
    prettier             # js/ts/json
    # typst cli for compile/watch outside the editor, tinymist embeds its own compiler
    typst
    websocat # relays the typst preview to the browser
    jupyterEnv # jupyter and python on PATH, for kernels and pip workflows
    jlab       # headless lab in a throwaway firefox window, dies with the window
    nodejs     # runtime for the markdown-preview.nvim server
  ];

  # fuzzy finder. fd backs the widgets, so Ctrl+T and Alt+C honor .gitignore and skip hidden files
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    fileWidget.command = "fd --type f";
    changeDirWidget.command = "fd --type d";
    defaultOptions = [ "--height 40%" "--layout reverse" "--border" ];
  };

  # delta as git's diff pager, home-side to stay next to the git config, not in systemPackages
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;     # n and N jump between diff sections
      line-numbers = true;
    };
  };

  # a repo's .envrc loads its devShell on cd, unloads on leave.
  # nix-direnv caches the shell, instant re-entry, safe from gc
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # delta as lazygit's pager. pagers array, not the old paging object (0.62+)
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --paging=never";
        }
      ];
    };
  };
}
