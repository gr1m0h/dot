local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- lua library
  'nvim-lua/plenary.nvim',
  'nvim-neotest/nvim-nio',
  'MunifTanjim/nui.nvim',
  -- notify
  {
    'rcarriga/nvim-notify',
    tag = 'v3.15.0',
    event = 'VimEnter',
    config = function()
      require('config.nvim-notify')
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
    tag = 'v3.15.0',
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
    tag = 'v1.3.0',
    config = function()
      require('config.nvim-lspconfig')
    end,
  },
  {
    'williamboman/mason.nvim',
    tag = 'v1.10.0',
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    tag = 'v1.31.0',
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
    tag = 'v3.6.0',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'j-hui/fidget.nvim',
    tag = 'v1.5.0',
    opts = {},
  },
  -------------------------------
  -- auto completion
  {
    'hrsh7th/nvim-cmp',
    tag = 'v0.0.2',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lsp-document-symbol',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'zbirenbaum/copilot-cmp',
      'onsails/lspkind.nvim',
    },
    config = function()
      require('config.nvim-cmp')
    end,
  },
  {
    'hrsh7th/cmp-nvim-lsp',
    lazy = true,
  },
  {
    'hrsh7th/cmp-nvim-lsp-signature-help',
    lazy = true,
  },
  {
    'hrsh7th/cmp-nvim-lsp-document-symbol',
    lazy = true,
  },
  {
    'hrsh7th/cmp-nvim-lua',
    lazy = true,
  },
  {
    'hrsh7th/cmp-buffer',
    lazy = true,
  },
  {
    'hrsh7th/cmp-path',
    lazy = true,
  },
  {
    'saadparwaiz1/cmp_luasnip',
    lazy = true,
  },
  {
    'zbirenbaum/copilot-cmp',
    lazy = true,
    config = function()
      require('copilot_cmp').setup()
    end
  },
  {
    'onsails/lspkind.nvim',
    lazy = true,
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
    tag = '0.1.8',
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
    build = ':TSUpdate',
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
    tag = 'v4.9.1',
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
    tag = 'v3.8.7',
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
    tag = 'v3.3.3',
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
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false,
    opts = {
      provider = 'copilot',
      auto_suggestions_provider = "copilot",
      behaviour = {
        auto_suggestions = true,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = true,
        support_paste_from_clipboard = true,
      },
      windows = {
        position = "right",
        width = 30,
        sidebar_header = {
          align = "center",
          rounded = false,
        },
        ask = {
          floating = true,
          start_insert = true,
          border = "rounded"
        }
      },
      copilot = {
        model = "gpt-4o-2024-05-13",
        -- model = "gpt-4o-mini",
        max_tokens = 4096,
      },
    },
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-tree/nvim-web-devicons',
      'zbirenbaum/copilot.lua',
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
  -------------------------------------------------
  --
  -- Debug Adapter Protocol
  --
  -------------------------------
  {
    'mfussenegger/nvim-dap',
    tag = '0.9.0',
    dependencies = {
      'wojciech-kulik/xcodebuild.nvim',
    },
    config = function()
      require('config.nvim-dap')
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    tag = 'v4.0.0',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      require('config.nvim-dap-ui')
    end,
  },
  -- {
  --   'jay-babu/mason-nvim-dap.nvim',
  --   tag = 'v2.4.0',
  --   config = function()
  --     require('config.mason-nvim-dap')
  --   end,
  -- },
  -------------------------------------------------
  --
  -- Programming Language
  --
  -------------------------------
  {
    'wojciech-kulik/xcodebuild.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('config.xcodebuild')
    end,
  },
})
