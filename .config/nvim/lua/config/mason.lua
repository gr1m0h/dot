-- https://github.com/williamboman/mason.nvim

local status, mason = pcall(require, "mason")
if (not status) then return end

mason.setup {}
