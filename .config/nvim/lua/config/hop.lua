-- https://github.com/phaazon/hop.nvim

local status, hop = pcall(require, 'hop')
if (not status) then return end

hop.setup {
	keys = 'etovxqpdygfblzhckisuran'
}
