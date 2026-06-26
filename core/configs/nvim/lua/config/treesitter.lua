-- treesitter highlighting from neovim core, grammars and queries come from nix.
-- prepend the nix dir to the runtimepath, where neovim finds parser/<lang>.so and queries/.
-- required after lazy in init.lua, lazy resets the runtimepath at startup.
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/treesitter")

-- enable highlighting per buffer, start() picks the parser from the filetype.
-- pcall: a filetype with no grammar keeps default highlighting instead of erroring.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
