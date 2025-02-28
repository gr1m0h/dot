-- https://github.com/neovim/nvim-lspconfig

local status, config = pcall(require, 'lspconfig')
if (not status) then return end

local navic = require('nvim-navic')
local set = vim.keymap.set

local on_attach = function(client, bufnr)
  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('Format', { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end
    })
  end
end

local on_attach_navic = function(client, bufnr)
  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('Format', { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end
    })
  end
  -- navic
  navic.attach(client, bufnr)
end

-- cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- sql
config.sqlls.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
}
-- lua
config.lua_ls.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        globals = { 'vim', 'use' },
      },
    },
  },
}
-- docker
config.dockerls.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
}
-- go
config.gopls.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
  cmd = { 'gopls', 'serve' },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      codelenses = {
        run_vulncheck_exp = true,
      },
    },
  },
}
-- terraform
config.terraformls.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
  filetypes = { 'terraform', 'tf' },
  cmd = { 'terraform-ls', 'serve' },
}
-- javascript / typescript
config.ts_ls.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
  filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
  cmd = { 'typescript-language-server', '--stdio' },
}
-- kotlin
config.kotlin_language_server.setup {
  on_attach = on_attach_navic,
  capabilities = capabilities,
  filetypes = { 'kotlin' },
}

-- Not managed by mason-lspconfig
config.sourcekit.setup {
  on_attach = on_attach_navic,
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  cmd = {
    'sourcekit-lsp',
    '-Xswiftc',
    '-sdk',
    '-Xswiftc',
    vim.fn.system('xcrun --sdk iphonesimulator --show-sdk-path'),
    '-Xswiftc',
    '-target',
    '-Xswiftc',
    -- 'x86_64-apple-ios`xcrun --sdk iphonesimulator --show-sdk-platform-version`-simulator',
    'x86_64-apple-ios18.2-simulator',
  },
}

config.dartls.setup {}

-- Not managed by mason-ls

-- keybind
set('n', 'li', ':LspInfo<Return>', { noremap = true, silent = true })
set('n', 'ls', ':LspStart<Return>', { noremap = true, silent = true })
