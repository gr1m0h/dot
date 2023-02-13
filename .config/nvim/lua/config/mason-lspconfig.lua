-- https://github.com/williamboman/mason-lspconfig.nvim

local status, masonlsp = pcall(require, 'mason-lspconfig')
if (not status) then return end

masonlsp.setup {
	ensure_installed = {
		'sqls',
		'lua_ls',
		'dockerls',
		'gopls',
		'rome',
		'tsserver',
		'terraformls',
		'yamlls',
		'marksman',
	}
}
