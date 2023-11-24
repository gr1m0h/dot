-- https://github.com/nvim-treesitter/nvim-treesitter

local status, ts = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

ts.setup {
  ensure_installed = {
    'astro',
    'bash',
    'css',
    'dart',
    'dockerfile',
    'go',
    'hcl',
    'html',
    'javascript',
    'json',
    'kotlin',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'sql',
    'swift',
    'terraform',
    'tsx',
    'typescript',
    'vim',
    'yaml',
  },
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  autotag = {
    enable = true,
  },
  -- indent plugin
  -- https://github.com/yioneko/nvim-yati
  yati = { enable = true },
}

vim.keymap.set('n', 'ts', ':TSUpdateSync<Return>', { noremap = true })
