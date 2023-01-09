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
		-- package manager
		use {
			'wbthomason/packer.nvim',
			config = function()
				vim.keymap.set('n', 'pi', ':PackerInstall<Return>', { noremap = true })
				vim.keymap.set('n', 'ps', ':PackerSync<Return>', { noremap = true })
			end
		}
		-----------------------------
		--
		-- Utils
		--
		-------------------------------
		-- faster lua plugin loading
		use 'lewis6991/impatient.nvim'
		-- all the lua functions
		use {
			'nvim-lua/plenary.nvim',
			module = 'plenary',
		}
		-- faster file format identification
		use 'nathom/filetype.nvim'
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
			config = function()
				require('which-key').setup {}
			end
		}
		-- A project which translate Vim documents into Japanese.
		use 'vim-jp/vimdoc-ja'
		-----------------------------
		--
		-- Notify
		--
		-------------------------------
		-- notification manager
		use {
			'rcarriga/nvim-notify',
			event = 'VimEnter',
			config = function()
				vim.notify = require('notify')
        require('notify').setup {}
			end
		}
		-------------------------------
		--
		-- Color Scheme
		--
		-------------------------------
		-- dracula theme
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
		-- completion plugin
		use {
			'hrsh7th/nvim-cmp',
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
		-- for neovim's built-in language server client
		use {
			'hrsh7th/cmp-nvim-lsp',
			after = 'nvim-cmp',
		}
		-- displaying function signatures with the current parameter emphasized
		use {
			'hrsh7th/cmp-nvim-lsp-signature-help',
			after = 'nvim-cmp',
		}
		-- textDocument/documentSymbol via nvim-lsp
		use {
			'hrsh7th/cmp-nvim-lsp-document-symbol',
			after = 'nvim-cmp',
		}
		-- neovim lua api
		use {
			'hrsh7th/cmp-nvim-lua',
			after = 'nvim-cmp',
		}
		-- buffer words
		use {
			'hrsh7th/cmp-buffer',
			after = 'nvim-cmp',
		}
		-- filesystem paths
		use {
			'hrsh7th/cmp-path',
			after = 'nvim-cmp',
		}
		-- luasnip completion source
		use {
			'saadparwaiz1/cmp_luasnip',
			after = 'nvim-cmp',
		}
		-- for treesitter
		use {
			'ray-x/cmp-treesitter',
			after = 'nvim-cmp',
		}
		-------------------------------
		--
		-- Language Server Protocol(LSP)
		--
		-------------------------------
		-- quickstart configurations for the neovim LSP client
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
		-- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
		use {
			'williamboman/mason-lspconfig.nvim',
			config = function()
				require('config.mason-lspconfig')
			end,
		}
		-- mason-null-ls bridges mason.nvim with the null-ls plugin - making it easier to use both plugins together
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
			config = function()
				require('config.nvim-dap')
			end,
		}
		-- A UI for nvim-dap
		use {
			'rcarriga/nvim-dap-ui',
			require = {
				'mfussenegger/nvim-dap',
				'nvim-treesitter/nvim-treesitter',
			},
			config = function()
				require('config.nvim-dap-ui')
			end,
		}
		-- Neovim can be used as a language server to inject LSP diagnostics, code actions, etc. via Lua
		use 'jose-elias-alvarez/null-ls.nvim'
		-------------------------------
		--
		-- Snippet
		--
		-------------------------------
		-- set of preconfigured snippets for different languages
		use {
			'rafamadriz/friendly-snippets',
			event = 'VimEnter',
		}
		-- snippet engine for neovim
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
		-- treesitter for neovim
		use {
			'nvim-treesitter/nvim-treesitter',
			event = 'VimEnter',
			run = 'TSUpdate',
			config = function()
				require('config.nvim-treesitter')
			end,
		}
		-- indent plugin of treesitter
		use {
			'yioneko/nvim-yati',
			after = 'nvim-treesitter',
		}
		-- show code context
		use {
			'romgrk/nvim-treesitter-context',
			cmd = { 'TSContextEnable' },
			after = 'nvim-treesitter',
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
		-- indent
		use {
			'lukas-reineke/indent-blankline.nvim',
			event = 'VimEnter',
			config = function()
				require('config.indent-blankline')
			end,
		}
		-- A light-weight lsp plugin based on neovim's built-in lsp with a highly performant UI.
		use {
			'glepnir/lspsaga.nvim',
			branch = 'main',
			config = function()
				require('config.lspsaga')
			end,
		}
		-- A snazzy bufferline for Neovim
		use {
			'akinsho/bufferline.nvim',
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
		-- motions on speed!
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
		-- highlight, navigate, and manipulate sets of matched text
		use {
			'andymass/vim-matchup',
			after = { 'nvim-treesitter' },
		}
		-- autopairs
		use {
			'windwp/nvim-autopairs',
			event = 'VimEnter',
			config = function()
				require('nvim-autopairs').setup {
					disable_filetype = { 'TelescopePrompt', 'vim' }
				}
			end,
		}
		-- use treesitter to auto close and auto rename html tag
		use {
			'windwp/nvim-ts-autotag',
			requires = { { 'nvim-treesitter/nvim-treesitter', opt = true } },
			after = { 'nvim-treesitter' },
			config = function()
				require('nvim-ts-autotag').setup {}
			end,
		}
		-- vim plugin for extensible and universal comments that can also handle embedded file types
		use 'tomtom/tcomment_vim'
		-- editorconfig for vim
		use {
			'editorconfig/editorconfig-vim',
			event = 'VimEnter',
		}
		-- Distraction-free coding for neovim
		use {
			'folke/zen-mode.nvim',
			config = function()
				vim.keymap.set('n', 'zm', ':ZenMode<Return>', { noremap = true, silent = true })
			end,
		}
		-------------------------------
		--
		-- Appearance
		--
		-------------------------------
		-- status line
		use {
			'nvim-lualine/lualine.nvim',
			after = dracula,
			-- web devicons
			requires = { 'nvim-tree/nvim-web-devicons', opt = true },
			config = function()
				require('config.lualine')
			end,
		}
		-- statusline component
		use {
			'SmiteshP/nvim-gps',
			requires = { { 'nvim-treesitter/nvim-treesitter', opt = true } },
			after = { 'nvim-treesitter' },
			config = function()
				require('nvim-gps').setup {}
			end,
		}
		-- The fastest Neovim colorizer.
		use 'norcalli/nvim-colorizer.lua'
		-- vscode-like pictograms for neovim lsp completion items
		use 'onsails/lspkind.nvim'
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
		use 'nvim-telescope/telescope-hop.nvim'
		-------------------------------
		--
		-- Git
		--
		-------------------------------
		-- Git integration for buffers
		use {
			'lewis6991/gitsigns.nvim',
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
		use {
			'iamcco/markdown-preview.nvim',
			ft = { 'markdown' },
			run = ':call mkdp#util#install()',
			setup = function()
				vim.keymap.set("n", "pv", ":MarkdownPreview<Return>", { noremap = true, silent = true })
			end,
		}
		use {
			'dhruvasagar/vim-table-mode',
			cmd = { 'TableModeEnable' },
		}
	end,
}
