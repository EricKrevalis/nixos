-- statusline: mode, file, git branch and diff, diagnostics, position.
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",          -- follows the colorscheme, revisit at the stylix pass
      globalstatus = true,     -- one bar for all splits, not one per window
      section_separators = "", -- flat, no powerline glyphs
      component_separators = "",
    },
  },
}
