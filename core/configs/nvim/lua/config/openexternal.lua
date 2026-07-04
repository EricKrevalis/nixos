-- files that aren't for editing get handed to a gui app, then the buffer is wiped.
-- ipynb goes to jupyter lab, the rest through xdg-open to swayimg/zathura/mpv.

local grp = vim.api.nvim_create_augroup("open_external", { clear = true })

-- extensions xdg-open should claim
local xdg_ext = {
  "pdf", "png", "jpg", "jpeg", "gif", "webp", "bmp", "svg",
  "mp4", "mkv", "webm", "mp3", "flac", "wav",
}

-- launch the gui app detached, then drop the buffer nvim opened for the file
local function handoff(argv)
  local file = vim.fn.expand("<afile>:p")
  local buf = vim.fn.bufnr(file)
  local cmd = vim.list_extend(vim.deepcopy(argv), { file })
  vim.fn.jobstart(cmd, { detach = true })
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.cmd("bwipeout! " .. buf)
    end
  end)
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = grp,
  pattern = "*.ipynb",
  callback = function() handoff({ "jlab" }) end,
})

-- match both cases, some files come capitalised
local pats = {}
for _, e in ipairs(xdg_ext) do
  pats[#pats + 1] = "*." .. e
  pats[#pats + 1] = "*." .. e:upper()
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = grp,
  pattern = pats,
  callback = function() handoff({ "xdg-open" }) end,
})
