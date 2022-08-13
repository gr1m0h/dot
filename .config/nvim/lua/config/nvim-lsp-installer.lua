require('nvim-lsp-installer').setup {
  ensure_installed = {
    'dockerls',
    'gopls',
    'quick_lint_js',
    'terraformls',
    'tsserver',
    'yamlls',
  },
  automatic_installation = true,
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗"
    }
  }
}
