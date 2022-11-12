-- https://github.com/SmiteshP/nvim-gps
--  Deprecated! Use nvim-navic instead of this plugin
--  https://github.com/SmiteshP/nvim-navic

local status, gps = pcall(require, 'nvim-gps')
if (not status) then return end

gps.setup {}
