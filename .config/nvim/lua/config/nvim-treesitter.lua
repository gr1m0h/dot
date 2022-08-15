-- https://github.com/nvim-treesitter/nvim-treesitter

local status, ts = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

ts.setup {
  ensure_installed = {
    'bash',
    'css',
    'dockerfile',
    'fish',
    'go',
    'hcl',
    'html',
    'javascript',
    'json',
    'lua',
    'make',
    'python',
    'ruby',
    'rust',
    'scss',
    'toml',
    'typescript',
    'vim',
    'vue',
    'yaml',
  },
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  -- indent plugin
  -- https://github.com/yioneko/nvim-yati
  yati = { enable = true },
}
