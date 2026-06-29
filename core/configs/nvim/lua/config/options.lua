-- editor behavior. vim.opt is the lua handle for :set options.
local opt = vim.opt

opt.number = true
opt.relativenumber = true -- distances for quick j/k jumps, absolute on the current line

opt.mouse = "a"
opt.showmode = false -- mode lives in the statusline later, not the command line

-- yank/paste through the system clipboard, served by wl-clipboard on wayland
opt.clipboard = "unnamedplus"

opt.breakindent = true -- wrapped lines keep their indent
opt.undofile = true    -- persistent undo across sessions

opt.ignorecase = true
opt.smartcase = true -- case-sensitive only once a capital is typed

opt.signcolumn = "yes" -- always reserve the gutter so text doesn't jump
opt.updatetime = 250   -- ms of idle before swap write and CursorHold
opt.timeoutlen = 300   -- ms to wait for a mapped sequence, e.g. after leader

opt.splitright = true
opt.splitbelow = true

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- show otherwise invisible whitespace

opt.inccommand = "split" -- live preview of :substitute
opt.cursorline = true
opt.scrolloff = 10 -- keep 10 lines of context above and below the cursor

-- 2-space indent, tabs expanded to spaces
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- treesitter folds, files open fully expanded so folding only happens on demand
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevelstart = 99

opt.termguicolors = true -- 24-bit color, foot supports it
