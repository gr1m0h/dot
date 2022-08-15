-- https://github.com/windwp/nvim-autopairs

local status, autopairs = pcall(require, 'nvim-autopairs')
if (not status) then return end

autopairs.setup {
  -- map the <CR> key
  map_cr = false,
}
