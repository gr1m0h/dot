-- https://github.com/rcarriga/nvim-dap-ui

local status, dapui = pcall(require, 'dapui')
if (not status) then return end

local dap = require('dap')

dapui.setup {
  floating = {
    border = 'rounded',
  },
}

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

vim.keymap.set('v', '<Leader>de', dapui.eval)
