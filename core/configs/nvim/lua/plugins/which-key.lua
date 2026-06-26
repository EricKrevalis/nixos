-- popup that lists the keys that can follow a prefix, read from the desc on each keymap.
-- turns the leader key into a discoverable menu instead of something to memorize.
return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- load after startup, nothing needs it before the first keypress
  opts = {
    delay = 400, -- ms held on a prefix before the popup opens
    spec = {
      -- label the prefix groups so the menu reads "find" not a bare <leader>f
      { "<leader>f", group = "find" },
      { "<leader>c", group = "code" },
    },
  },
}
