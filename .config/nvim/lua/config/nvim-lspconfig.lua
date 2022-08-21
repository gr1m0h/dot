-- https://github.com/neovim/nvim-lspconfig

local status, config = pcall(require,'lspconfig')
if (not status) then return end

-- lua
config.sumneko_lua.setup{
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        globals = { 'vim', 'use' },
      },
    }
  },
}
-- docker
config.dockerls.setup{}
-- go
config.gopls.setup{
  cmd = { 'gopls', 'serve' },
}
-- js
config.quick_lint_js.setup{}
-- terraform
config.terraformls.setup{}
-- typescript
config.tsserver.setup{}
-- yaml
config.yamlls.setup{}

vim.keymap.set('n', 'li', ':LspInfo<Return>', { noremap = true })
vim.keymap.set('n', 'ls', ':LspStart<Return>', { noremap = true })
