local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system { 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.api.nvim_command 'packadd packer.nvim'
end

local status, packer = pcall(require, 'packer')
if (not status) then return end

packer.init {
  display = {
    open_fn = require 'packer.util'.float,
  },
}

packer.startup {
  function()
    -------------------------------------------------
    --
    -- Installer
    --
    -------------------------------
    use {
      -- A use-package inspired plugin manager for Neovim. Uses native packages, supports Luarocks dependencies, written in Lua, allows for expressive config
      'wbthomason/packer.nvim',
      config = function()
        vim.keymap.set('n', 'ps', ':PackerSync<Return>', { noremap = true, silent = true })
      end
    }
    use {
      -- Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters.
      'williamboman/mason.nvim',
      config = function()
        require('mason').setup {}
      end,
    }
    -------------------------------------------------
    --
    -- Library
    --
    -------------------------------
    -- Lua Library
    use {
      -- Improve startup time for Neovim
      'lewis6991/impatient.nvim',
    }
    use {
      -- plenary: full; complete; entire; absolute; unqualified. All the lua functions I don't want to write twice.
      'nvim-lua/plenary.nvim',
    }
    -------------------------------
    -- Notify
    use {
      -- A fancy, configurable, notification manager for NeoVim
      'rcarriga/nvim-notify',
      event = 'VimEnter',
      config = function()
        local notify = require('notify')
        vim.notify = notify
        notify.history()
        notify.setup {}
      end
    }
    -------------------------------
    -- Colorscheme
    local dracula = 'dracula.nvim'
    use {
      -- Dracula colorscheme for neovim written in Lua
      'Mofiqul/dracula.nvim',
      config = function()
        vim.cmd [[ colorscheme dracula ]]
      end,
    }
    -------------------------------
    -- Font
    use {
      -- lua `fork` of vim-web-devicons for neovim
      'nvim-tree/nvim-web-devicons',
      config = function()
        require('nvim-web-devicons').setup {}
      end,
    }
    -------------------------------------------------
    --
    -- Standard Feature Enhancement
    --
    -------------------------------
    -- Manual
    use {
      -- Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
      'folke/which-key.nvim',
      tag = 'v1.0.0',
      config = function()
        require('which-key').setup {}
      end
    }
    use {
      -- A project which translate Vim documents into Japanese.
      'vim-jp/vimdoc-ja',
    }
    use {
      -- Viewing plugin's README easily like vim help
      '4513ECHO/vim-readme-viewer',
      opt = true,
      cmd = 'PackerReadme',
      config = function()
        vim.g['readme_viewer#plugin_manager'] = 'packer.nvim'
      end
    }
    -------------------------------------------------
    --
    -- LSP & Completion
    --
    -------------------------------
    -- Language Server Protocol(LSP)
    use {
      'neovim/nvim-lspconfig',
      -- Quickstart configs for Nvim LSP
      after = { 'cmp-nvim-lsp' },
      cmd = { 'LspInfo', 'LspLog' },
      config = function()
        require('config.nvim-lspconfig')
      end,
    }
    use {
      -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim. Strongly recommended for Windows users.
      'williamboman/mason-lspconfig.nvim',
      config = function()
        require('config.mason-lspconfig')
      end,
    }
    use {
      -- neovim lsp plugin
      'glepnir/lspsaga.nvim',
      branch = 'main',
      config = function()
        require('config.lspsaga')
      end,
    }
    use {
      -- 🚦 A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.
      'folke/trouble.nvim',
      requires = 'nvim-tree/nvim-web-devicons',
      config = function()
        require('trouble').setup {}
      end,
    }
    use {
      -- Standalone UI for nvim-lsp progress
      'j-hui/fidget.nvim',
      config = function()
        require('fidget').setup {}
      end,
    }
    -------------------------------
    -- Auto Completion
    local cmp = 'nvim-cmp'
    use {
      -- A completion plugin for neovim coded in Lua.
      'hrsh7th/nvim-cmp',
      tag = 'v0.0.1',
      requires = {
        { 'L3MON4D3/LuaSnip', opt = true, event = 'VimEnter' },
        { 'windwp/nvim-autopairs', opt = true, event = 'VimEnter' },
      },
      after = { 'LuaSnip', 'nvim-autopairs' },
      config = function()
        require('config.nvim-cmp')
      end,
    }
    use {
      -- nvim-cmp source for neovim builtin LSP client
      'hrsh7th/cmp-nvim-lsp',
      after = cmp,
    }
    use {
      -- cmp-nvim-lsp-signature-help
      'hrsh7th/cmp-nvim-lsp-signature-help',
      after = cmp,
    }
    use {
      -- nvim-cmp source for textDocument/documentSymbol via nvim-lsp.
      'hrsh7th/cmp-nvim-lsp-document-symbol',
      after = cmp,
    }
    use {
      -- nvim-cmp source for nvim lua
      'hrsh7th/cmp-nvim-lua',
      after = cmp,
    }
    use {
      -- nvim-cmp source for buffer words
      'hrsh7th/cmp-buffer',
      after = cmp,
    }
    use {
      -- nvim-cmp source for vim's cmdline
      'hrsh7th/cmp-cmdline',
      after = cmp,
    }
    use {
      -- nvim-cmp source for path
      'hrsh7th/cmp-path',
      after = cmp,
    }
    use {
      -- luasnip completion source for nvim-cmp
      'saadparwaiz1/cmp_luasnip',
      after = cmp,
    }
    use {
      -- cmp source for treesitter
      'ray-x/cmp-treesitter',
      run = ':TSUpdate',
      after = cmp,
    }
    use {
      -- vscode-like pictograms for neovim lsp completion items
      'onsails/lspkind.nvim',
    }
    -------------------------------------------------
    --
    -- Editing
    --
    -------------------------------
    -- Moving
    use {
      -- Neovim motions on speed!
      'phaazon/hop.nvim',
      branch = 'v2',
      config = function()
        require('config.hop')
      end,
    }
    -------------------------------------------------
    --
    -- Fuzzy finder, Filer
    --
    -------------------------------
    -- telescope
    use {
      -- Find, Filter, Preview, Pick. All lua, all the time.
      'nvim-telescope/telescope.nvim',
      tag = '0.1.0',
      requires = { 'plenary.nvim' },
      config = function()
        require('config.telescope')
      end,
    }
    use {
      -- File Browser extension for telescope.nvim
      'nvim-telescope/telescope-file-browser.nvim',
      requires = { 'telescope.nvim' },
    }
    -- (Teles-)Hopping to the moon.
    -- use 'nvim-telescope/telescope-hop.nvim'
    -------------------------------
    -- treesitter
    local ts = 'nvim-treesitter'
    use {
      -- Nvim Treesitter configurations and abstraction layer
      'nvim-treesitter/nvim-treesitter',
      event = 'VimEnter',
      run = 'TSUpdate',
      config = function()
        require('config.nvim-treesitter')
      end,
    }
    use {
      -- Yet another tree-sitter powered indent plugin for Neovim.
      'yioneko/nvim-yati',
      after = ts,
    }
    use {
      -- Show code context
      'romgrk/nvim-treesitter-context',
      cmd = { 'TSContextEnable' },
      after = ts,
    }
    use {
      -- Use treesitter to auto close and auto rename html tag
      'windwp/nvim-ts-autotag',
      requires = { { 'nvim-treesitter/nvim-treesitter', opt = true } },
      after = ts,
      config = function()
        require('nvim-ts-autotag').setup {}
      end,
    }
    -------------------------------------------------
    --
    -- Appearance
    --
    -------------------------------
    -- Statusline
    use {
      -- A blazing fast and easy to configure neovim statusline plugin written in pure lua.
      'nvim-lualine/lualine.nvim',
      after = dracula,
      -- web devicons
      requires = { 'nvim-tree/nvim-web-devicons', opt = true },
      config = function()
        require('config.lualine')
      end,
    }
    use {
      -- Simple winbar/statusline plugin that shows your current code context
      'SmiteshP/nvim-navic',
      requires = 'neovim/nvim-lspconfig',
    }
    -------------------------------
    -- Bufferline
    use {
      -- A snazzy bufferline for Neovim
      'akinsho/bufferline.nvim',
      tag = 'v3.1.0',
      requires = 'nvim-tree/nvim-web-devicons',
      config = function()
        require('bufferline').setup {}
      end,
    }
    -------------------------------
    -- Syntax
    use {
      -- The fastest Neovim colorizer.
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('colorizer').setup {}
      end
    }
    -------------------------------
    -- Filetype detection
    use {
      -- A faster version of filetype.vim
      'nathom/filetype.nvim',
      tag = 'v0.4',
    }
    -------------------------------
    -- Layout
    use {
      -- 🧘 Distraction-free coding for Neovim
      'folke/zen-mode.nvim',
      config = function()
        vim.keymap.set('n', 'zm', ':ZenMode<Return>', { noremap = true, silent = true })
      end,
    }
    -------------------------------
    -- Navigation
    use {
      -- Neovim plugin for a code outline window
      'stevearc/aerial.nvim',
      config = function()
        require('aerial').setup {}
      end
    }
    -------------------------------------------------
    --
    -- Coding
    --
    -------------------------------
    -- Snippet
    use {
      -- Set of preconfigured snippets for different languages.
      'rafamadriz/friendly-snippets',
      event = 'VimEnter',
    }
    use {
      -- Snippet Engine for Neovim written in Lua.
      'L3MON4D3/LuaSnip',
      after = { 'friendly-snippets' },
      config = function()
        require('config.LuaSnip')
      end,
    }
    -------------------------------
    -- Template
    use {
      -- Easy and high speed coding method
      'mattn/vim-sonictemplate'
    }
    -------------------------------
    -- Debugger
    use {
      -- Debug Adapter Protocol client implementation for Neovim
      'mfussenegger/nvim-dap',
      tag = '0.3.0',
      config = function()
        require('config.nvim-dap')
      end,
    }
    use {
      -- A UI for nvim-dap
      'rcarriga/nvim-dap-ui',
      tag = 'v2.6.0',
      require = {
        'mfussenegger/nvim-dap',
        'nvim-treesitter/nvim-treesitter',
      },
      config = function()
        require('config.nvim-dap-ui')
      end,
    }
    -------------------------------
    -- Git
    use {
      -- Git integration for buffers
      'lewis6991/gitsigns.nvim',
      tag = 'v0.6',
      config = function()
        require('gitsigns').setup {}
      end,
    }
    -------------------------------
    -- Reading assistant
    use {
      -- Indent guides for Neovim
      'lukas-reineke/indent-blankline.nvim',
      event = 'VimEnter',
      config = function()
        require('config.indent-blankline')
      end,
    }
    -------------------------------
    -- Comment out
    use {
      -- An extensible & universal comment vim-plugin that also handles embedded filetypes
      'tomtom/tcomment_vim',
    }
    -------------------------------
    -- Brackets
    use {
      -- vim match-up: even better % 👊 navigate and highlight matching words 👊 modern matchit and matchparen. Supports both vim and neovim + tree-sitter.
      'andymass/vim-matchup',
      after = ts,
    }
    use {
      -- autopairs for neovim written by lua
      'windwp/nvim-autopairs',
      event = 'VimEnter',
      config = function()
        require('nvim-autopairs').setup {
          disable_filetype = { 'TelescopePrompt', 'vim' }
        }
      end,
    }
    -------------------------------
    -- Lint
    use 'jose-elias-alvarez/null-ls.nvim'
    use {
      'jayp0521/mason-null-ls.nvim',
      require = {
        'williamboman/mason.nvim',
        'jose-elias-alvarez/null-ls.nvim',
      },
      config = function()
        require('config.mason-null-ls')
      end
    }
    -------------------------------------------------
    --
    -- Programming Languages
    --
    -------------------------------
    -- Markdown
    use {
      -- markdown preview plugin for (neo)vim
      'iamcco/markdown-preview.nvim',
      tag = 'v0.0.10',
      ft = { 'markdown' },
      run = ':call mkdp#util#install()',
      setup = function()
        vim.keymap.set("n", "pv", ":MarkdownPreview<Return>", { noremap = true, silent = true })
      end,
    }
    use {
      -- VIM Table Mode for instant table creation.
      'dhruvasagar/vim-table-mode',
      cmd = { 'TableModeEnable' },
    }
  end,
}
