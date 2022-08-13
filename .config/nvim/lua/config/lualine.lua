-- https://github.com/nvim-lualine/lualine.nvim

local function is_available_gps()
  local ok, _ = pcall(require, "nvim-gps")
  if not ok then
    return false
  end
  return require("nvim-gps").is_available()
end

require('lualine').setup {
  theme = 'dracula'
}