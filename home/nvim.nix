{ config, pkgs, ... }:

{
  # nvim theming stays with lazy.nvim, stylix stays out
  stylix.targets.neovim.enable = false;

  # out-of-store symlink to the live repo, lua edits are instant, lazy writes lazy-lock.json back. neovim from packages.nix
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/nixos/configs/nvim";

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
  # the preview server runs on the system nodejs from modules/packages.nix.
  xdg.dataFile."nvim/mkdp".source = pkgs.vimPlugins.markdown-preview-nvim;

  # no warnings on loose files without a compile db, -Wall covers the useful ones
  xdg.configFile."clangd/config.yaml".text = ''
    CompileFlags:
      Add:
        - -Wall
        # - -Wextra  # unused params, sign-compare, noisier. per-project if wanted
  '';

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
  ];
}
