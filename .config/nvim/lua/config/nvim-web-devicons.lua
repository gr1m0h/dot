-- https://github.com/nvim-tree/nvim-web-devicons

local status, devicons  = pcall(require, "nvim-web-devicons")
if (not status) then return end

devicons.setup{}
