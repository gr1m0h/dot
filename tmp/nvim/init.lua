-- load plugins
vim.opt.termguicolors = true
if vim.g.vscodee then
  require('vscode')
else
  require('plugins')
end

-- disable default plugins
local disable_plugins = {
  'loaded_gzip',
  'loaded_shada_plugin',
  'loadedzip',
  'loaded_spellfile_plugin',
  'loaded_tutor_mode_plugin',
  'loaded_tar',
  'loaded_tarPlugin',
  'loaded_zip',
  'loaded_zipPlugin',
  'loaded_rrhelper',
  'loaded_2html_plugin',
  'loaded_vimball',
  'loaded_vimballPlugin',
  'loaded_getscript',
  'loaded_getscriptPlugin',
  'loaded_matchparen',
  'loaded_matchit',
  'loaded_man',
  'loaded_netrw',
  'loaded_netrwPlugin',
  'loaded_netrwSettings',
  'loaded_netrwFileHandlers',
  'loaded_logiPat',
  'loaded_remote_plugins',
  'did_load_filetypes',
  'did_load_ftplugin',
  'did_indent_on',
  'did_install_default_menus',
  'did_install_syntax_menu',
  'skip_loading_mswin',
}

for _, name in pairs(disable_plugins) do
  vim.g[name] = 1
end

-- config
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1'
vim.o.fileformats = 'unix,dos,mac'

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
vim.g.editorconfig = true

vim.opt.shortmess:append({ I = true })
vim.opt.showmode = true
vim.opt.mouse = 'a'
vim.opt.laststatus = 3
vim.opt.helplang = 'ja'
vim.opt.termguicolors = true

-- use program
vim.g.python3_host_prog = '$HOME/.asdf/shims/python3'
vim.g.ruby_host_prog = '$HOME/.asdf/shims/ruby'

-- checkhealth
vim.keymap.set('n', 'ch', ':checkhealth<Return>', { noremap = true })

vim.cmd 'set noshowmode'
