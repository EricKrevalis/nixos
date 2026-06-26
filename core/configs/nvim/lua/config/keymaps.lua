-- keymaps that don't belong to a plugin. plugin binds ship with their plugin.
local map = vim.keymap.set

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- move between splits with ctrl + hjkl instead of ctrl-w then hjkl
map("n", "<C-h>", "<C-w>h", { desc = "focus split left" })
map("n", "<C-j>", "<C-w>j", { desc = "focus split down" })
map("n", "<C-k>", "<C-w>k", { desc = "focus split up" })
map("n", "<C-l>", "<C-w>l", { desc = "focus split right" })

-- backspace toggles the alternate file (the # buffer), faster than reaching for <C-^>
map("n", "<BS>", "<C-^>", { desc = "toggle alternate file" })
