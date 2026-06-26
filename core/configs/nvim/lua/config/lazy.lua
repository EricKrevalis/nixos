-- bootstrap lazy.nvim into the data dir, it clones itself on first launch.
-- data dir is writable, unlike the config dir which is a repo symlink.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- load every spec under lua/plugins/, one file per plugin
  spec = {
    { import = "plugins" },
  },
  -- luarocks off, on nix a rock would come from a package, not lazy building hererocks
  rocks = { enabled = false },
})
