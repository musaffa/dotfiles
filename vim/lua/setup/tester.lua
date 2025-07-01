-- Vim Test
vim.g['test#strategy'] = 'neovim'

-- keymaps
vim.keymap.set('n', '<leader>tt', ':TestNearest<CR>', { silent = true })
vim.keymap.set('n', '<leader>tf', ':TestFile<CR>', { silent = true })
vim.keymap.set('n', '<leader>ta', ':TestSuite<CR>', { silent = true })
vim.keymap.set('n', '<leader>tl', ':TestLast<CR>', { silent = true })
vim.keymap.set('n', '<leader>tg', ':TestVisit<CR>', { silent = true })

-- local neotest = require 'neotest'
--
-- neotest.setup {
--   adapters = {
--     require 'neotest-rspec',
--   },
-- }
--
-- vim.keymap.set('n', '<leader>tt', neotest.run.run, {})
-- vim.keymap.set('n', '<leader>ts', neotest.run.stop, {})
--
-- vim.keymap.set('n', '<leader>td', function()
--   neotest.run.run { strategy = 'dap' }
-- end, {})
--
-- vim.keymap.set('n', '<leader>tf', function()
--   neotest.run.run(vim.fn.expand '%')
-- end, {})
--
-- vim.keymap.set('n', '<leader>ta', function()
--   neotest.run.run { suite = true }
-- end, {})
--
-- vim.keymap.set('n', '<leader>tl', neotest.run.run_last, {})
-- vim.keymap.set('n', '<leader>to', neotest.output_panel.toggle, {})
-- vim.keymap.set('n', '<leader>tc', neotest.output_panel.clear, {})
