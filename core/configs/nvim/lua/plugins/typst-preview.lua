-- live typst preview in the browser, follows the cursor. opens with the file, closes with it.
return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  opts = {
    -- its own firefox, closing the preview never touches your real one
    -- fixed window name, the cleanup below closes just this window
    -- reused profile, skips the first-run private-browsing tab
    open_cmd = 'D="${XDG_DATA_HOME:-$HOME/.local/share}/firefox-previews/typst"; mkdir -p "$D" && '
      .. 'MOZ_APP_REMOTINGNAME=typst-preview firefox --no-remote --profile "$D" --private-window %s',
    -- binaries from nix, the plugin downloads its own otherwise
    dependencies_bin = {
      tinymist = "tinymist",
      websocat = "websocat",
    },
  },
  config = function(_, opts)
    require("typst-preview").setup(opts)

    local group = vim.api.nvim_create_augroup("typst_preview_auto", { clear = true })

    -- close the preview window, does nothing if it's already gone
    local function close_window()
      vim.system({ "swaymsg", '[app_id="typst-preview"] kill' })
    end

    -- open the preview as soon as a typst file opens, it updates live, no save needed
    local function start(buf)
      if vim.b[buf].typst_preview_started then return end
      vim.b[buf].typst_preview_started = true
      vim.cmd("TypstPreview")
    end

    -- on :q, stop this file's server and close its window
    -- the plugin only cleans up on full exit, closing one file alone would leave both running
    local function stop(buf)
      if not vim.b[buf].typst_preview_started then return end
      vim.b[buf].typst_preview_started = nil
      -- TypstPreviewStop acts on the focused file, focus this one first
      vim.api.nvim_buf_call(buf, function() vim.cmd("TypstPreviewStop") end)
      close_window()
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "typst",
      callback = function(ev) start(ev.buf) end,
    })
    vim.api.nvim_create_autocmd("BufUnload", {
      group = group,
      pattern = "*.typ",
      callback = function(ev) stop(ev.buf) end,
    })
    -- safety net on :qa, kill any preview window left behind
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = close_window,
    })

    -- the file that loaded this plugin already passed its autostart trigger, start it here
    if vim.bo.filetype == "typst" then start(0) end
  end,
}
