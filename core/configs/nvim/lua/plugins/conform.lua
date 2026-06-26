-- formatter runner, one tool per language, binaries from the nix dev layer.
-- format on demand with <leader>cf, not on save, so nothing reshapes a file unasked.
return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    { "<leader>cf", function() require("conform").format({ async = true }) end, desc = "format buffer" },
  },
  opts = {
    default_format_opts = { lsp_format = "fallback" }, -- use the lsp formatter where no tool is listed
    formatters_by_ft = {
      nix = { "nixfmt" },
      lua = { "stylua" },
      python = { "ruff_organize_imports", "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
  },
}
