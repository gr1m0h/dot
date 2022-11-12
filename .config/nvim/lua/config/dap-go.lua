-- https://github.com/leoluz/nvim-dap-go

local status, dapgo = pcall(require, 'dap-go')
if (not status) then return end

dapgo.setup {}
