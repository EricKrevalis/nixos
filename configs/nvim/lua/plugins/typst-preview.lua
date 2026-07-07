-- live typst preview in the browser, follows the cursor.
-- one preview at a time, it hands off to whichever typst file is focused.
-- two previews would collide on the single reused firefox profile lock and sync would die.
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

    -- buffer that currently owns the one preview, nil when none is up
    local active = nil

    -- close the preview window, does nothing if it's already gone
    local function close_window()
      vim.system({ "swaymsg", '[app_id="typst-preview"] kill' })
    end

    -- stop the preview the active buffer owns, if any
    local function stop_active()
      if not active then return end
      local buf = active
      active = nil
      if vim.api.nvim_buf_is_valid(buf) then
        vim.b[buf].typst_preview_started = nil
        -- TypstPreviewStop acts on the focused file, focus this one first
        vim.api.nvim_buf_call(buf, function() vim.cmd("TypstPreviewStop") end)
      end
      close_window()
    end

    -- hand the single preview to the focused typst buffer, stopping the old owner first.
    -- callers fire this only from the focused buffer, TypstPreview lands on the right file
    local function switch_to(buf)
      if active == buf then return end
      stop_active()
      active = buf
      vim.b[buf].typst_preview_started = true
      vim.cmd("TypstPreview")
    end

    -- focusing a typst file takes the preview over to it
    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,
      pattern = "*.typ",
      callback = function(ev)
        if vim.bo[ev.buf].filetype == "typst" then switch_to(ev.buf) end
      end,
    })
    -- closing the owner stops the preview, another open typst file reopens it on BufEnter
    vim.api.nvim_create_autocmd("BufUnload", {
      group = group,
      pattern = "*.typ",
      callback = function(ev)
        if active == ev.buf then stop_active() end
      end,
    })
    -- safety net on :qa, kill any preview window left behind
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = close_window,
    })

    -- the file that loaded this plugin already passed its BufEnter, start it here
    if vim.bo.filetype == "typst" then switch_to(vim.api.nvim_get_current_buf()) end
  end,
}
