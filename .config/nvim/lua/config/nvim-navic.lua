-- https://github.com/SmiteshP/nvim-navic

local status, navic = pcall(require, 'nvim-navic')
if (not status) then return end

require('lspconfig').clangd.setup {
  on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
  end
}
