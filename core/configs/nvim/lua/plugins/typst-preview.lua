-- live typst preview in the browser, follows the cursor. :TypstPreview to start.
return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    -- throwaway firefox window, off the main profile
    open_cmd = "firefox --private-window %s",
    -- binaries from nix, the plugin downloads its own otherwise
    dependencies_bin = {
      tinymist = "tinymist",
      websocat = "websocat",
    },
  },
  config = function(_, opts)
    require("typst-preview").setup(opts)
    -- autostart on opening a typst file. the preview is live, no :w needed to refresh
    local function start(buf)
      if vim.b[buf].typst_preview_started then return end
      vim.b[buf].typst_preview_started = true
      vim.cmd("TypstPreview")
    end
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "typst",
      callback = function(ev) start(ev.buf) end,
    })
    -- the buffer that lazy-loaded this plugin already fired its FileType
    if vim.bo.filetype == "typst" then start(0) end
  end,
}
