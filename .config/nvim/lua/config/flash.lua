-- https://github.com/folke/flash.nvim

local status, flash = pcall(require, 'flash')
if (not status) then return end

local config = require('flash.config')
local char = require('flash.plugins.char')
for _, motion in ipairs({ 'f', 't', 'F', 'T' }) do
  vim.keymap.set({ 'n', 'x', 'o' }, motion, function()
    flash.jump(config.get({
      mode = 'char',
      search = {
        mode = char.mode(motion),
        max_length = 1,
      },
    }, char.motions[motion]))
  end)
end
