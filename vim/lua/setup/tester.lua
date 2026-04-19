-- Vim Test
vim.g['test#strategy'] = 'neovim'

-- keymaps
vim.keymap.set('n', '<leader>tt', ':TestNearest<CR>', { silent = true })
vim.keymap.set('n', '<leader>tf', ':TestFile<CR>', { silent = true })
vim.keymap.set('n', '<leader>ta', ':TestSuite<CR>', { silent = true })
vim.keymap.set('n', '<leader>tl', ':TestLast<CR>', { silent = true })
vim.keymap.set('n', '<leader>tg', ':TestVisit<CR>', { silent = true })
