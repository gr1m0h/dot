local status, saga = pcall(require, "lspsaga")
if (not status) then return end

saga.init_lsp_saga {
}

local action = require("lspsaga.codeaction")
-- code action
vim.keymap.set("n", "<leadeer>ca", action.code_action, { silent = true })
vim.keymap.set("v", "<leader>ca", function()
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-U>", true, false, true))
    action.range_code_action()
end, { silent = true })
-- or use command
vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { silent = true })
vim.keymap.set("v", "<leader>ca", "<cmd><C-U>Lspsaga range_code_action<CR>", { silent = true })

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>j", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
vim.keymap.set("n", "<leader>d", "<cmd>Lspsaga hover_doc<CR>", opts)
vim.keymap.set("n", "<leader>f", "<cmd>Lspsaga lsp_finder<CR>", opts)
vim.keymap.set("i", "<leader>h", "<cmd>Lspsaga signature_help<CR>", opts)
vim.keymap.set("n", "<leader>p", "<cmd>Lspsaga preview_definition<CR>", opts)
vim.keymap.set("n", "<leader>r", "<cmd>Lspsaga rename<CR>", opts)
