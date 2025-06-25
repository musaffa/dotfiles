-- free c-l from netrw's plug mapping
vim.keymap.set('n', '<leader><leader><leader>l', '<Plug>NetrwRefresh')

-- Telescope
vim.keymap.set('n', '<leader>f', '<cmd>lua require("telescope.builtin").find_files()<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>s', '<cmd>lua require("telescope.builtin").live_grep()<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fb','b <cmd>lua require("telescope.builtin").buffers()<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fh','h <cmd>lua require("telescope.builtin").help_tags()<cr>', { noremap=true, silent=true })

-- Vim test mappings
vim.keymap.set('n', '<leader>t', ':TestNearest<CR>', { silent=true })
vim.keymap.set('n', '<leader>T', ':TestFile<CR>', { silent=true })
vim.keymap.set('n', '<leader>a', ':TestSuite<CR>', { silent=true })
vim.keymap.set('n', '<leader>l', ':TestLast<CR>', { silent=true })
vim.keymap.set('n', '<leader>g', ':TestVisit<CR>', { silent=true })

-- Neovim terminal mappings
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', { noremap=true })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { noremap=true })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { noremap=true })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { noremap=true })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { noremap=true })

-- Map the missing Y yank
vim.keymap.set('n', 'Y', 'y$', { noremap=true, silent=true })

-- Prettify Json files
vim.keymap.set('n', '<Leader>fj', ':%!jq .<CR>', { noremap=true })
