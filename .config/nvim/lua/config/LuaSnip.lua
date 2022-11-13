-- https://github.com/L3MON4D3/LuaSnip

local status, ls = pcall(require, "luasnip")
if (not status) then return end

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
  delete_check_events = "TextChanged",
  -- luasnip uses this function to get the currently active filetype.
  -- This is the (rather uninteresting) default, but it"s possible to use
  -- -- eg. treesitter for getting the current filetype by setting ft_func to
  -- require("luasnip.extras.filetype_functions").from_cursor (requires`nvim-treesitter/nvim-treesitter`).
  -- This allows correctly resolving the current filetype in eg. a markdown-code block or `vim.cmd()`.
  ft_func = function()
    return vim.split(vim.bo.filetype, ".", true)
  end,
}
