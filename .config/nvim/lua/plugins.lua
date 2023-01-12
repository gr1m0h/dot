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
    -- A use-package inspired plugin manager for Neovim. Uses native packages, supports Luarocks dependencies, written in Lua, allows for expressive config
    use {
      'wbthomason/packer.nvim',
      config = function()
        vim.keymap.set('n', 'ps', ':PackerSync<Return>', { noremap = true })
      end
    }
    -----------------------------
    --
    -- Utils
    --
    -------------------------------
    -- Improve startup time for Neovim
    use 'lewis6991/impatient.nvim'
    -- plenary: full; complete; entire; absolute; unqualified. All the lua functions I don't want to write twice.
    use 'nvim-lua/plenary.nvim'
    -- A faster version of filetype.vim
    use {
      'nathom/filetype.nvim',
      tag = 'v0.4',
    }
    -- Viewing plugin's README easily like vim help
    use {
      '4513ECHO/vim-readme-viewer',
      opt = true,
      cmd = 'PackerReadme',
      config = function()
        vim.g['readme_viewer#plugin_manager'] = 'packer.nvim'
      end
    }
    -- Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
    use {
      'folke/which-key.nvim',
      tag = 'v1.0.0',
      config = function()
        require('which-key').setup {}
      end
    }
    -- A project which translate Vim documents into Japanese.
    use 'vim-jp/vimdoc-ja'
    -- A fancy, configurable, notification manager for NeoVim
    use {
      'rcarriga/nvim-notify',
      event = 'VimEnter',
      config = function()
        local notify = require('notify')
        vim.notify = notify
        notify.history()
        notify.setup {}
      end
    }
    -- Dracula colorscheme for neovim written in Lua
    local dracula = 'dracula.nvim'
    use {
      'Mofiqul/dracula.nvim',
      config = function()
        vim.cmd [[ colorscheme dracula ]]
      end,
    }
    -------------------------------
    --
    -- Auto Completion
    --
    -------------------------------
    -- A completion plugin for neovim coded in Lua.
    local cmp = 'nvim-cmp'
    use {
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
    --------------------
    -- nvim-cmp sources
    --------------------
    -- nvim-cmp source for neovim builtin LSP client
    use {
      'hrsh7th/cmp-nvim-lsp',
      after = cmp,
    }
    -- cmp-nvim-lsp-signature-help
    use {
      'hrsh7th/cmp-nvim-lsp-signature-help',
      after = cmp,
    }
    -- nvim-cmp source for textDocument/documentSymbol via nvim-lsp.
    use {
      'hrsh7th/cmp-nvim-lsp-document-symbol',
      after = cmp,
    }
    -- nvim-cmp source for nvim lua
    use {
      'hrsh7th/cmp-nvim-lua',
      after = cmp,
    }
    -- nvim-cmp source for buffer words
    use {
      'hrsh7th/cmp-buffer',
      after = cmp,
    }
    -- nvim-cmp source for path
    use {
      'hrsh7th/cmp-path',
      after = cmp,
    }
    -- luasnip completion source for nvim-cmp
    use {
      'saadparwaiz1/cmp_luasnip',
      after = cmp,
    }
    -- cmp source for treesitter
    use {
      'ray-x/cmp-treesitter',
      after = cmp,
    }
    -------------------------------
    --
    -- Language Server Protocol(LSP)
    --
    -------------------------------
    -- Quickstart configs for Nvim LSP
    use {
      'neovim/nvim-lspconfig',
      after = { 'cmp-nvim-lsp' },
      cmd = { 'LspInfo', 'LspLog' },
      config = function()
        require('config.nvim-lspconfig')
      end,
    }
    -- Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters.
    use {
      'williamboman/mason.nvim',
      config = function()
        require('mason').setup {}
      end,
    }
    -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim. Strongly recommended for Windows users.
    use {
      'williamboman/mason-lspconfig.nvim',
      config = function()
        require('config.mason-lspconfig')
      end,
    }
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
    -- Debug Adapter Protocol client implementation for Neovim
    use {
      'mfussenegger/nvim-dap',
      tag = '0.3.0',
      config = function()
        require('config.nvim-dap')
      end,
    }
    -- A UI for nvim-dap
    use {
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
    use 'jose-elias-alvarez/null-ls.nvim'
    -- neovim lsp plugin
    use {
      'glepnir/lspsaga.nvim',
      branch = 'main',
      config = function()
        require('config.lspsaga')
      end,
    }
    -------------------------------
    --
    -- Snippet
    --
    -------------------------------
    -- Set of preconfigured snippets for different languages.
    use {
      'rafamadriz/friendly-snippets',
      event = 'VimEnter',
    }
    -- Snippet Engine for Neovim written in Lua.
    use {
      'L3MON4D3/LuaSnip',
      after = { 'friendly-snippets' },
      config = function()
        require('config.LuaSnip')
      end,
    }
    -------------------------------
    --
    -- Treesitter
    --
    -------------------------------
    -- Nvim Treesitter configurations and abstraction layer
    local ts = 'nvim-treesitter'
    use {
      'nvim-treesitter/nvim-treesitter',
      event = 'VimEnter',
      run = 'TSUpdate',
      config = function()
        require('config.nvim-treesitter')
      end,
    }
    -- Yet another tree-sitter powered indent plugin for Neovim.
    use {
      'yioneko/nvim-yati',
      after = ts,
    }
    -- Show code context
    use {
      'romgrk/nvim-treesitter-context',
      cmd = { 'TSContextEnable' },
      after = ts,
    }
    -- Use treesitter to auto close and auto rename html tag
    use {
      'windwp/nvim-ts-autotag',
      requires = { { 'nvim-treesitter/nvim-treesitter', opt = true } },
      after = ts,
      config = function()
        require('nvim-ts-autotag').setup {}
      end,
    }
    -------------------------------
    --
    -- Reading
    --
    -------------------------------
    -- lua `fork` of vim-web-devicons for neovim
    use {
      'nvim-tree/nvim-web-devicons',
      config = function()
        require('nvim-web-devicons').setup {}
      end,
    }
    -- Indent guides for Neovim
    use {
      'lukas-reineke/indent-blankline.nvim',
      event = 'VimEnter',
      config = function()
        require('config.indent-blankline')
      end,
    }
    -- A snazzy bufferline for Neovim
    use {
      'akinsho/bufferline.nvim',
      tag = 'v3.1.0',
      requires = 'nvim-tree/nvim-web-devicons',
      config = function()
        require('bufferline').setup {}
      end,
    }
    -------------------------------
    --
    -- Moving
    --
    -------------------------------
    -- Neovim motions on speed!
    use {
      'phaazon/hop.nvim',
      branch = 'v2',
      config = function()
        require('config.hop')
      end,
    }
    -------------------------------
    --
    -- Editing
    --
    -------------------------------
    -- vim match-up: even better % 👊 navigate and highlight matching words 👊 modern matchit and matchparen. Supports both vim and neovim + tree-sitter.
    use {
      'andymass/vim-matchup',
      after = ts,
    }
    -- autopairs for neovim written by lua
    use {
      'windwp/nvim-autopairs',
      event = 'VimEnter',
      config = function()
        require('nvim-autopairs').setup {
          disable_filetype = { 'TelescopePrompt', 'vim' }
        }
      end,
    }
    -- An extensible & universal comment vim-plugin that also handles embedded filetypes
    use 'tomtom/tcomment_vim'
    -- EditorConfig plugin for Vim
    use {
      'editorconfig/editorconfig-vim',
      event = 'VimEnter',
    }
    -- 🧘 Distraction-free coding for Neovim
    use {
      'folke/zen-mode.nvim',
      config = function()
        vim.keymap.set('n', 'zm', ':ZenMode<Return>', { noremap = true, silent = true })
      end,
    }
    -- Easy and high speed coding method
    use {
      'mattn/vim-sonictemplate'
    }
    -------------------------------
    --
    -- Appearance
    --
    -------------------------------
    -- A blazing fast and easy to configure neovim statusline plugin written in pure lua.
    use {
      'nvim-lualine/lualine.nvim',
      after = dracula,
      -- web devicons
      requires = { 'nvim-tree/nvim-web-devicons', opt = true },
      config = function()
        require('config.lualine')
      end,
    }
    -- Simple statusline component that shows what scope you are working inside
    use {
      'SmiteshP/nvim-gps',
      requires = { { 'nvim-treesitter/nvim-treesitter', opt = true } },
      after = ts,
      config = function()
        require('nvim-gps').setup {}
      end,
    }
    -- The fastest Neovim colorizer.
    use 'norcalli/nvim-colorizer.lua'
    -- vscode-like pictograms for neovim lsp completion items
    use 'onsails/lspkind.nvim'
    -- 🚦 A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.
    use {
      'folke/trouble.nvim',
      requires = 'nvim-tree/nvim-web-devicons',
      config = function()
        require('trouble').setup {}
      end,
    }
    -------------------------------
    --
    -- Fuzzy finder, Filer
    --
    -------------------------------
    -- Find, Filter, Preview, Pick. All lua, all the time.
    use {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.0',
      requires = { 'plenary.nvim' },
      config = function()
        require('config.telescope')
      end,
    }
    -- File Browser extension for telescope.nvim
    use {
      'nvim-telescope/telescope-file-browser.nvim',
      requires = { 'telescope.nvim' },
    }
    -- (Teles-)Hopping to the moon.
    -- use 'nvim-telescope/telescope-hop.nvim'
    -------------------------------
    --
    -- Git
    --
    -------------------------------
    -- Git integration for buffers
    use {
      'lewis6991/gitsigns.nvim',
      tag = 'v0.6',
      config = function()
        require('gitsigns').setup {}
      end,
    }
    -------------------------------
    --
    -- Languages
    --
    -------------------------------
    -- markdown
    -- markdown preview plugin for (neo)vim
    use {
      'iamcco/markdown-preview.nvim',
      tag = 'v0.0.10',
      ft = { 'markdown' },
      run = ':call mkdp#util#install()',
      setup = function()
        vim.keymap.set("n", "pv", ":MarkdownPreview<Return>", { noremap = true, silent = true })
      end,
    }
    -- VIM Table Mode for instant table creation.
    use {
      'dhruvasagar/vim-table-mode',
      cmd = { 'TableModeEnable' },
    }
  end,
}
