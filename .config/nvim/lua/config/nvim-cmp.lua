-- https://github.com/hrsh7th/nvim-cmp

local status, cmp = pcall(require, "cmp")
if (not status) then return end

local luasnip = require("luasnip")
local lspkind = require("lspkind")

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true
		}),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "nvim_lsp_document_symbol" },
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "luasnip" },
		{ name = "treesitter" },
	}),
	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
			maxwidth = 50,
		})
	},
}

vim.g.completeopt = "menu,menuone,noselect"
vim.cmd [[
  highlight! default link CmpItemKind CmpItemMenuDefault
]]

-- autopairs
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
