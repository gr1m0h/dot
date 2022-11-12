-- https://github.com/lewis6991/gitsigns.nvim

local status, git = pcall(require, 'gitsigns')
if (not status) then return end

git.setup {}
