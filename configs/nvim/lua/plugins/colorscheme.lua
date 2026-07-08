-- palette file written by home/nvim.nix from the stylix scheme
-- same setup() call stylix's own neovim target makes
return {
  "RRethy/base16-nvim",
  priority = 1000,
  lazy = false,
  config = function()
    local palette = dofile(vim.fn.stdpath("data") .. "/stylix-colors.lua")
    require("base16-colorscheme").setup(palette)
  end,
}
