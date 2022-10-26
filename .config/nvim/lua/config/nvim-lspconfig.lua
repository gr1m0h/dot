-- https://github.com/neovim/nvim-lspconfig

local status, config = pcall(require,'lspconfig')
if (not status) then return end

-- sql
config.sqls.setup{}
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
  autostart = true,
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

local goimports = function(timeout_ms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result or next(result) == nil then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

vim.api.nvim_create_autocmd(
  {"BufWritePre"}, {
  pattern = { "*.go" },
  callback = function()
	  vim.lsp.buf.formatting_sync(nil, 3000)
  end,
})

vim.api.nvim_create_autocmd(
  {"BufWritePre"}, {
  pattern = { "*.go" },
  callback = function()
	  goimports(1000)
  end,
})

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
