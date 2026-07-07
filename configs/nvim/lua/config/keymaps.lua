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

-- v = vertical line (side by side), b = horizontal line (top/bottom)
-- s/n = smart: vsplit when the window is wider than tall, split otherwise.
-- columns/2 converts char-columns to an approximate pixel width (chars are ~2x taller than wide)
local function smart_split(new_buf)
  local w = vim.api.nvim_win_get_width(0)
  local h = vim.api.nvim_win_get_height(0)
  if w / 2 > h then
    vim.cmd(new_buf and "vnew" or "vsplit")
  else
    vim.cmd(new_buf and "new" or "split")
  end
end

local smart_same = function() smart_split(false) end
local smart_new  = function() smart_split(true) end

-- bind both the released and ctrl-held form of each key.
-- ctrl held sends e.g. <C-w><C-n>, else it falls through to the built-in split.
map("n", "<C-w>v",     "<cmd>vsplit<CR>", { desc = "vertical (left/right)" })
map("n", "<C-w><C-v>", "<cmd>vsplit<CR>", { desc = "vertical (left/right)" })
map("n", "<C-w>b",     "<cmd>split<CR>",  { desc = "horizontal (top/bottom)" })
map("n", "<C-w><C-b>", "<cmd>split<CR>",  { desc = "horizontal (top/bottom)" })
map("n", "<C-w>s",     smart_same,        { desc = "smart (auto, same buffer)" })
map("n", "<C-w><C-s>", smart_same,        { desc = "smart (auto, same buffer)" })
map("n", "<C-w>n",     smart_new,         { desc = "smart (auto, new buffer)" })
map("n", "<C-w><C-n>", smart_new,         { desc = "smart (auto, new buffer)" })
