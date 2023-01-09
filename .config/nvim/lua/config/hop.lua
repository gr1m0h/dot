-- https://github.com/phaazon/hop.nvim

local status, hop = pcall(require, "hop")
if (not status) then return end


hop.setup {
  keys = "etovxqpdygfblzhckisuran"
}

local directions = require('hop.hint').HintDirection
local set = vim.keymap.set

set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, { remap = true })

set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, { remap = true })

set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, { remap = true })

set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, { remap = true })
