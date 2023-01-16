-- https://github.com/neovim/nvim-lspconfig

local status, config = pcall(require, 'lspconfig')
if (not status) then return end

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

-- cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- sql
config.sqls.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
-- lua
config.sumneko_lua.setup {
	on_attach = on_attach,
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
	on_attach = on_attach,
	capabilities = capabilities,
}
-- go
config.gopls.setup {
	on_attach = on_attach,
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
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { 'terraform', 'tf' },
	cmd = { 'terraform-ls', 'serve' },
}
-- javascript / typescript
config.tsserver.setup {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
	cmd = { 'typescript-language-server', '--stdio' },
}
config.rome.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
-- markdown
config.marksman.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
-- yaml
config.yamlls.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}

set('n', 'li', ':LspInfo<Return>', { noremap = true })
set('n', 'ls', ':LspStart<Return>', { noremap = true })
