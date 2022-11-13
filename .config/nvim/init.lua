require("plugins")

-- config
vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"
vim.o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1"
vim.o.fileformats = "unix,dos,mac"

vim.o.number = true
vim.o.wrap = true

vim.g.noexpandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = true
vim.o.hlsearch = true
vim.o.wildmenu = true

vim.g.noswapfile = true
vim.g.nobackup = true
vim.g.noundofile = true

vim.opt.shortmess:append({ I = true })
vim.opt.showmode = true
vim.opt.mouse = "a"

-- use program
vim.g.python3_host_prog = "$HOME/.asdf/shims/python3"
vim.g.ruby_host_prog = "$HOME/.asdf/shims/ruby"

-- keybindings
local set = vim.keymap.set
-- packer
set("n", "pi", ":PackerInstall<Return>", { noremap = true })
set("n", "ps", ":PackerSync<Return>", { noremap = true })

-- checkhealth
set("n", "ch", ":checkhealth<Return>", { noremap = true })
