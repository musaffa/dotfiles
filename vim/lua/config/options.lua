-- If you don't understand a setting in here, just type ':h setting'.

-- Set Leader key
vim.g.mapleader = ','

vim.o.linebreak = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.colorcolumn = '81'

-- Set Clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- TAB settings
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

-- Window settings
vim.o.splitright = true
vim.o.splitbelow = true

-- Theme
vim.o.termguicolors = true

-- Backup settings
vim.o.writebackup = false

-- Vim diff split
vim.opt.diffopt:append 'vertical'

vim.filetype.add {
  extension = {
    hbs = 'handlebars',
  },
}
