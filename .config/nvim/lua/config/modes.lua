-- https://github.com/mvllow/modes.nvim

local status, modes = pcall(require, 'modes')
if (not status) then return end

modes.setup {
	colors = {
		insert = '#78CC96',
		visual = '#E2FF2B',
	}
}
