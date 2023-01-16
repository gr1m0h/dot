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
		'tsx',
		'vim',
		'vue',
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
