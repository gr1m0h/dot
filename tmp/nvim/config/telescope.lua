-- https://github.com/nvim-telescope/telescope.nvim

local status, telescope = pcall(require, 'telescope')
if (not status) then return end

local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
local trouble = require('trouble.providers.telescope')

local function telescope_buffer_dir()
	return vim.fn.expand('%:p:h')
end

local fb_actions = require('telescope').extensions.file_browser.actions

telescope.setup {
	defaults = {
		mappings = {
			i = {
				['t'] = trouble.open_with_trouble,
			},
			n = {
				['t'] = trouble.open_with_trouble,
				['q'] = actions.close,
			},
		},
	},
	extensions = {
		file_browser = {
			theme = 'dropdown',
			-- disables netrw and use telescope-file-browser in its place
			hijack_netrw = true,
			mappings = {
				-- your custom insert mode mappings
				['i'] = {
					['<C-w>'] = function() vim.cmd('normal vbd') end,
				},
				['n'] = {
					-- your custom normal mode mappings
					['N'] = fb_actions.create,
					['h'] = fb_actions.goto_parent_dir,
					['/'] = function()
						vim.cmd('startinsert')
					end
				},
			},
		},
	},
}

telescope.load_extension('file_browser')

-- keymaps
local set = vim.keymap.set
set('n', 'fb', function()
	telescope.extensions.file_browser.file_browser({
		path = '%:p:h',
		cwd = telescope_buffer_dir(),
		respect_gitignore = false,
		hidden = true,
		grouped = true,
		previewer = false,
		initial_mode = 'normal',
		layout_config = { height = 40 }
	})
end)

set('n', ';f', function()
	builtin.find_files({
		no_ignore = false,
		hidden = true
	})
end)

set('n', ';g', function()
	builtin.live_grep()
end)

set('n', ';b', function()
	builtin.buffers()
end)

set('n', ';t', function()
	builtin.help_tags()
end)

set('n', ';r', function()
	builtin.resume()
end)

set('n', ';d', function()
	builtin.diagnostics()
end)
