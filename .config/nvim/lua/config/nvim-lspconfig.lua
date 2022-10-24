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

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go" },
  callback = function()
	  vim.lsp.buf.formatting_sync(nil, 3000)
  end,
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	pattern = { "*.go" },
-- 	callback = function()
-- 		local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
-- 		params.context = {only = {"source.organizeImports"}}
--
-- 		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
-- 		for _, res in pairs(result or {}) do
-- 			for _, r in pairs(res.result or {}) do
-- 				if r.edit then
-- 					vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
-- 				else
-- 					vim.lsp.buf.execute_command(r.command)
-- 				end
-- 			end
-- 		end
-- 	end,
-- })

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
