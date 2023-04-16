-- https://github.com/zbirenbaum/copilot.lua

local status, copilot = pcall(require, 'copilot')
if (not status) then return end


copilot.setup {
  suggestion = { enabled = false },
  pannel = { enabled = false },
}
