-- https://github.com/williamboman/mason-lspconfig.nvim

local status, masonlsp = pcall(require, 'mason-lspconfig')
if (not status) then return end

masonlsp.setup {
  ensure_installed = {
    'sqlls',
    'lua_ls',
    'dockerls',
    'gopls',
    'biome',
    'tsserver',
    'terraformls',
    'marksman',
    'kotlin_language_server'
  }
}
