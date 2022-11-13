-- https://github.com/neovim/nvim-lspconfig

local status, config = pcall(require, "lspconfig")
if (not status) then return end

local set = vim.keymap.set
local on_attach = function(client, bufnr)
	-- format on save
	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("Format", { clear = true }),
			buffer = bufnr,
			callback = function() vim.lsp.buf.format() end
		})
	end
end

-- sql
config.sqls.setup {
	on_attach = on_attach,
}
-- lua
config.sumneko_lua.setup {
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = {
				enable = true,
				globals = { "vim", "use" },
			},
		}
	},
}
-- docker
config.dockerls.setup {
	on_attach = on_attach,
}
-- go
config.gopls.setup {
	on_attach = on_attach,
	cmd = { "gopls", "serve" },
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
	filetypes = { "terraform", "tf" },
	cmd = { "terraform-ls", "serve" },
}
-- javascript / typescript
config.tsserver.setup {
	on_attach = on_attach,
	filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
	cmd = { "typescript-language-server", "--stdio" },
}
config.rome.setup {
	on_attach = on_attach,
}
-- markdown
config.marksman.setup {
	on_attach = on_attach,
}
-- yaml
config.yamlls.setup {
	on_attach = on_attach,
}

set("n", "li", ":LspInfo<Return>", { noremap = true })
set("n", "ls", ":LspStart<Return>", { noremap = true })
