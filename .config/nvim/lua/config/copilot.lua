-- https://github.com/zbirenbaum/copilot.lua

local status, copilot = pcall(require, 'copilot')
if (not status) then return end


copilot.setup {
  suggestion = { enabled = false },
  pannel = { enabled = false },
  server_opts_overrides = {
    trace = "verbose",
    cmd = {
      vim.fn.expand("~/.config/nvim/copilot/bin/copilot-language-server"),
      "--stdio"
    },
    settings = {
      advanced = {
        listCount = 10,
        inlineSuggestCount = 3,
      },
    },
  },
  filetypes = {
    yaml = true,
    markdown = true,
    help = false,
    gitcommit = true,
    gitrebase = true,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
    ["*"] = true,
  },
}
