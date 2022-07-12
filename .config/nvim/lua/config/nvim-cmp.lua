-- https://github.com/hrsh7th/nvim-cmp

vim.g.completeopt = 'menu,menuone,noselect'

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lsp_document_symbol' },
    { name = 'nvim_lua' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'cmdline' },
    { name = 'luasnip' },
    { name = 'treesitter' },
    { name = 'copilot' },
    { name = 'cmp_tabnine' },
    },
}

-- autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
