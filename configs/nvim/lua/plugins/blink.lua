-- completion menu, fed by lsp, snippets, buffer words and paths.
-- blink bundles its sources, snippet support and fuzzy matcher, no glue plugins needed.
return {
  "saghen/blink.cmp",
  version = "1.*", -- track 1.x releases, the lua matcher below means no rust binary to build
  event = "InsertEnter",
  opts = {
    -- default preset: Ctrl-space show, Ctrl-y accept, Ctrl-n/p select, Ctrl-e hide.
    -- enter stays a newline, nothing auto-accepts.
    keymap = { preset = "default" },
    completion = {
      menu = { auto_show = true },                                       -- show as you type
      list = { selection = { preselect = false, auto_insert = false } }, -- but never pick or insert on its own
      documentation = { auto_show = true, auto_show_delay_ms = 200 },    -- docs for the highlighted item
    },
    fuzzy = { implementation = "lua" }, -- pure lua, no compiler and no downloaded binary
  },
}
