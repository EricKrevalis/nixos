-- markdown preview in its own firefox window, opens only when asked.
-- :MarkdownPreview opens, :MarkdownPreviewStop closes. never auto-starts.
-- served from the nix-built copy, nothing to download.
return {
  "iamcco/markdown-preview.nvim",
  dir = vim.fn.stdpath("data") .. "/mkdp", -- nix store copy symlinked in
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_start = 0 -- never open on its own
    vim.g.mkdp_auto_close = 1 -- close the window when you leave the file
    -- its own firefox, closing the preview never touches your real one
    -- fixed window name, the cleanup below closes just this window
    vim.g.mkdp_browserfunc = "OpenMarkdownInFirefox"
    vim.cmd([[
      function! OpenMarkdownInFirefox(url) abort
        let l:profile = (empty($XDG_DATA_HOME) ? $HOME . '/.local/share' : $XDG_DATA_HOME) . '/firefox-previews/markdown'
        " reused profile, skips the first-run private-browsing tab
        call mkdir(l:profile, 'p')
        call jobstart('MOZ_APP_REMOTINGNAME=markdown-preview firefox --no-remote --profile '
          \ . shellescape(l:profile) . ' --private-window ' . shellescape(a:url))
      endfunction
    ]])

    -- auto_close only shuts the page, this makes sure the window closes too
    local group = vim.api.nvim_create_augroup("markdown_preview_auto", { clear = true })
    local function close_window()
      vim.system({ "swaymsg", '[app_id="markdown-preview"] kill' })
    end
    vim.api.nvim_create_autocmd("BufUnload", {
      group = group,
      pattern = "*.md",
      callback = close_window,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = close_window,
    })
  end,
}
