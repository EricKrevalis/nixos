-- markdown preview in a private firefox window, on demand only.
-- :MarkdownPreview opens, :MarkdownPreviewStop closes. no auto-start.
-- loaded from the nix-built copy, app prebuilt, so no download step.
return {
  "iamcco/markdown-preview.nvim",
  dir = vim.fn.stdpath("data") .. "/mkdp", -- nix store copy symlinked in
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_start = 0 -- never open on its own
    vim.g.mkdp_auto_close = 1 -- close the tab when leaving the buffer
    -- throwaway firefox window, off the main profile
    vim.g.mkdp_browserfunc = "OpenMarkdownInFirefox"
    vim.cmd([[
      function! OpenMarkdownInFirefox(url) abort
        call jobstart(['firefox', '--private-window', a:url])
      endfunction
    ]])
  end,
}
