-- https://github.com/hrsh7th/nvim-cmp

local status, cmp = pcall(require, 'cmp')
if (not status) then return end

local luasnip = require('luasnip')
local lspkind = require('lspkind')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
    ['<tab>'] = cmp.mapping(function(original)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        original()
      end
    end, { 'i', 's' }),
    ['<S-tab>'] = cmp.mapping(function(original)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.expand_or_jumbable() then
        luasnip.jump(-1)
      else
        original()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lsp_document_symbol' },
    { name = 'copilot' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lua' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      with_text = true,
      maxwidth = 50,
    })
  },
}

require 'cmp'.setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
  }, {
    { name = 'path' },
  }, {
    name = 'cmdline',
    option = {
      ignore_cmds = { 'Man', '!' }
    }
  })
})

vim.g.completeopt = 'menu,menuone,noselect'
vim.cmd [[
  highlight! default link CmpItemKind CmpItemMenuDefault
]]

-- autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
