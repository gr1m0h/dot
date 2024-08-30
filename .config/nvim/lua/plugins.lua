local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- lua library
  'nvim-lua/plenary.nvim',
  -- notify
  {
    'rcarriga/nvim-notify',
    tag = 'v3.13.2',
    event = 'VimEnter',
    config = function()
      local notify = require('notify')
      vim.notify = notify
      notify.history()
    end,
    opts = {},
  },
  -- colorscheme
  {
    'Mofiqul/dracula.nvim',
    config = function()
      vim.cmd [[ colorscheme dracula ]]
    end,
  },
  -- font
  {
    'nvim-tree/nvim-web-devicons',
    opts = {},
  },
  -- standard fatture enhancement
  {
    'folke/which-key.nvim',
    tag = 'v2.1.0',
    event = 'VeryLazy',
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },
  -------------------------------------------------
  --
  -- LSP & Completion
  --
  -------------------------------
  -- language server protocol
  {
    'neovim/nvim-lspconfig',
    tag = 'v0.1.7',
    config = function()
      require('config.nvim-lspconfig')
    end,
  },
  {
    'williamboman/mason.nvim',
    tag = 'v1.9.0',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    tag = 'v1.26.0',
    config = function()
      require('config.mason-lspconfig')
    end,
  },
  {
    'nvimdev/lspsaga.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('config.lspsaga')
    end,
  },
  {
    'folke/trouble.nvim',
    tag = 'v3.4.3',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'j-hui/fidget.nvim',
    tag = 'v1.4.1',
    opts = {},
  },
  -------------------------------
  -- auto completion
  {
    'hrsh7th/nvim-cmp',
    tag = 'v0.0.1',
    dependencies = {
      { 'L3MON4D3/LuaSnip',      lazy = true, event = 'VimEnter' },
      { 'windwp/nvim-autopairs', lazy = true, event = 'VimEnter' },
    },
    config = function()
      require('config.nvim-cmp')
    end,
  },
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'hrsh7th/cmp-nvim-lsp-document-symbol',
  'hrsh7th/cmp-nvim-lua',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-path',
  'saadparwaiz1/cmp_luasnip',
  {
    'ray-x/cmp-treesitter',
    build = ':TSUpdate',
  },
  {
    'lukas-reineke/cmp-rg',
    tag = 'v1.3.9',
  },
  {
    'zbirenbaum/copilot-cmp',
    config = function()
      require('copilot_cmp').setup()
    end
  },
  {
    'onsails/lspkind.nvim',
    config = function()
      require('config.lspkind')
    end
  },
  -------------------------------------------------
  --
  -- Fuzzy finder, Filer
  --
  -------------------------------
  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'plenary.nvim' },
    config = function()
      require('config.telescope')
    end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
  },
  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'VimEnter',
    build = 'TSUpdate',
    config = function()
      require('config.nvim-treesitter')
    end,
  },
  'yioneko/nvim-yati',
  {
    'romgrk/nvim-treesitter-context',
    cmd = { 'TSContextEnable' },
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = { { 'nvim-treesitter/nvim-treesitter', lazy = true } },
    opts = {},
    config = function()
      require('config.nvim-ts-autotag')
    end
  },
  -------------------------------------------------
  --
  -- Appearance
  --
  -------------------------------
  -- status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('config.lualine')
    end,
  },
  {
    'SmiteshP/nvim-navic',
    dependencies = { 'neovim/nvim-lspconfig' },
  },
  -------------------------------
  -- buffer line
  {
    'akinsho/bufferline.nvim',
    tag = 'v4.6.0',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {}
  },
  -------------------------------
  -- syntax
  {
    'norcalli/nvim-colorizer.lua',
    opts = {}
  },
  -------------------------------
  -- layout
  {
    'folke/zen-mode.nvim',
    config = function()
      vim.keymap.set('n', 'zm', ':ZenMode<Return>', { noremap = true, silent = true })
    end,
  },
  -------------------------------
  -- navigation
  {
    'stevearc/aerial.nvim',
    opts = {}
  },
  -------------------------------------------------
  --
  -- Coding
  --
  -------------------------------
  -- snippet
  {
    'rafamadriz/friendly-snippets',
    event = 'VimEnter',
  },
  {
    'L3MON4D3/LuaSnip',
    tag = 'v2.3.0',
    after = { 'friendly-snippets' },
    config = function()
      require('config.LuaSnip')
    end,
  },
  -------------------------------
  -- template
  'mattn/vim-sonictemplate',
  -------------------------------
  -- git
  {
    'lewis6991/gitsigns.nvim',
    tag = 'v0.9.0',
    opts = {}
  },
  -------------------------------
  -- reading assistant
  {
    'lukas-reineke/indent-blankline.nvim',
    tag = 'v3.6.3',
    main = 'ibl',
    opts = {},
  },
  -------------------------------
  -- comment out
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },
  -------------------------------
  -- brackets
  'andymass/vim-matchup',
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      disable_filetype = { 'TelescopePrompt', 'vim' }
    },
  },
  -------------------------------
  -- lint
  'nvimtools/none-ls.nvim',
  {
    'jay-babu/mason-null-ls.nvim',
    tag = 'v2.6.0',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'nvimtools/none-ls.nvim',
    },
    config = function()
      require('config.mason-null-ls')
    end,
  },
  -------------------------------------------------
  --
  -- AI
  --
  -------------------------------
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('config.copilot')
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    tag = 'v2.10.1',
    dependencies = {
      'zbirenbaum/copilot.lua',
      'nvim-lua/plenary.nvim',
    },
    opts = {
      debug = true,
    },
    config = function()
      require('config.CopilotChat')
    end,
  },
  -------------------------------------------------
  --
  -- Programming Language
  --
  -------------------------------
  -- markdown
  {
    'dhruvasagar/vim-table-mode',
    tag = 'v4.8.1',
    cmd = { 'TableModeEnable' },
  },
})
