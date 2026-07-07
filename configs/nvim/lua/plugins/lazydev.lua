-- feeds lua-language-server the neovim api when editing lua.
-- without it, vim.* shows up as undefined globals all over this config.
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {},
}
