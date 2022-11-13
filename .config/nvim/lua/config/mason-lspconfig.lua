-- https://github.com/williamboman/mason-lspconfig.nvim

local status, masonlsp = pcall(require, "mason-lspconfig")
if (not status) then return end

masonlsp.setup {
  ensure_installed = {
    "sqls",
    "sumneko_lua",
    "dockerls",
		"gopls",
		"rome",
    "tsserver",
    "terraformls",
    "yamlls",
    "marksman",
  }
}
