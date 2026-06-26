-- fuzzy finder over files, live grep, buffers and help. fd and ripgrep back it, both from nix.
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim", -- lua helper library telescope is built on
  },
  config = function()
    require("telescope").setup({})

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set
    map("n", "<leader>ff", builtin.find_files, { desc = "find files" })
    map("n", "<leader>fg", builtin.live_grep, { desc = "grep in files" })
    map("n", "<leader>fb", builtin.buffers, { desc = "open buffers" })
    map("n", "<leader>fr", builtin.oldfiles, { desc = "recent files" })
    map("n", "<leader>fh", builtin.help_tags, { desc = "help tags" })
  end,
}
