-- https://github.com/neovim/nvim-lspconfig

local config = require('lspconfig')

-- dockerls
config.dockerls.setup{}
-- gopls
config.gopls.setup{
  on_attach = on_attach,
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  cmd = { 'gopls', 'serve'},
}
-- quick_lint_js
config.quick_lint_js.setup{}
-- terraformls
config.terraformls.setup{}
-- tsserver
config.tsserver.setup{}
-- yamlls
config.yamlls.setup{}

vim.api.nvim_set_keymap('n', 'li', ':LspInfo<Return>', { noremap = true })
vim.api.nvim_set_keymap('n', 'lii', ':LspInstallInfo<Return>', { noremap = true })
