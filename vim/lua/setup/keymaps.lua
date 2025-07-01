-- Neovim terminal mappings
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', { noremap = true })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { noremap = true })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { noremap = true })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { noremap = true })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { noremap = true })

-- Map the missing Y yank
vim.keymap.set('n', 'Y', 'y$', { noremap = true, silent = true })

-- Prettify Json files
vim.keymap.set('n', '<Leader>pj', ':%!jq .<CR>', { noremap = true })
