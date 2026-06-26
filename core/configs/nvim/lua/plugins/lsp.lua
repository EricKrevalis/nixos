-- language servers: enable them, set keymaps, tune diagnostics.
-- the server binaries come from nix, nvim-lspconfig only supplies the launch defaults.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "saghen/blink.cmp" }, -- load blink first so we can hand its capabilities to the servers
  config = function()
    -- tell every server what blink can do, so completion offers full lsp items.
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

    -- ruff does lint and format only, basedpyright owns hover and types.
    -- pin ruff to basedpyright's utf-16 so the two agree on positions, and drop ruff's hover.
    vim.lsp.config("ruff", {
      capabilities = { general = { positionEncodings = { "utf-16" } } },
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
    })

    -- turn on the servers, defaults from nvim-lspconfig, binaries from the nix dev layer.
    vim.lsp.enable({
      "nixd",         -- nix
      "lua_ls",       -- lua
      "bashls",       -- bash
      "basedpyright", -- python types, completion, navigation
      "ruff",         -- python lint and format
      "marksman",     -- markdown
    })

    -- calm diagnostics: signs in the gutter, message on demand, nothing inline or while typing.
    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })

    -- buffer-local keys, set only once a server attaches.
    -- rename/refs/actions/hover are neovim 0.11 defaults (grn gra grr K), add only what's missing.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "definition")
        map("gD", vim.lsp.buf.declaration, "declaration")
        map("<leader>e", vim.diagnostic.open_float, "line diagnostics")
      end,
    })
  end,
}
