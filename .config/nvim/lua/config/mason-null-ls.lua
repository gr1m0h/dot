-- https://github.com/jayp0521/mason-null-ls.nvim

local status, masonnull = pcall(require, 'mason-null-ls')
if (not status) then return end

masonnull.setup {
  ensure_installed = {
    'goimports',
    'jq',
    'yamlfmt',
    'prettier',
    'markdownlint',
  },
  automatic_setup = true,
}
