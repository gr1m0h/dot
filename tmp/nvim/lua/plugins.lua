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
  'lewis6991/impatient.nvim',
  'nvim-lua/plenary.nvim',
  -- notify
  {
    'rcarriga/nvim-notify',
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
    config = function()
      require('config.nvim-lspconfig')
    end,
  },
  {
    'williamboman/mason.nvim',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
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
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'j-hui/fidget.nvim',
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
    tag = '0.1.4',
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
    tag = 'v3.1.0',
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
  -- ui
  {
    'stevearc/dressing.nvim',
    opts = {},
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
    tag = 'v0.6',
    opts = {}
  },
  -------------------------------
  -- reading assistant
  {
    'lukas-reineke/indent-blankline.nvim',
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
  -- Programming Language
  --
  -------------------------------
  -- markdown
  {
    'dhruvasagar/vim-table-mode',
    cmd = { 'TableModeEnable' },
  },
  -- flutter
  {
    'akinsho/flutter-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = true,
  }
})
