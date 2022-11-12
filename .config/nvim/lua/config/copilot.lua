-- https://github.com/zbirenbaum/copilot.lua

local status, copilot = pcall(require, 'copilot')
if (not status) then return end

vim.schedule(function()
	copilot.setup {}
end)
