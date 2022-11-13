-- https://github.com/akinsho/bufferline.nvim

local status, bufferline = pcall(require,"bufferline")
if (not status) then return end

bufferline.setup{}
