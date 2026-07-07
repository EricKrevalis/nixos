-- entry point, neovim sources this on startup

-- leader before lazy so plugin keymaps bind under it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.openexternal") -- hand ipynb/pdf/media off to gui apps
require("config.lazy")
require("config.treesitter") -- after lazy: it resets the runtimepath this prepends to
