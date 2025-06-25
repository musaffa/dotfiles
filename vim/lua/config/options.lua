-- If you don't understand a setting in here, just type ':h setting'.

-- Set Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = '81'

-- Set Clipboard
vim.opt.clipboard = 'unnamedplus'

-- TAB settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Window settings
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Theme
vim.opt.termguicolors = true

-- Backup settings
vim.opt.writebackup = false

-- Vim diff split
vim.opt.diffopt:append('vertical')
