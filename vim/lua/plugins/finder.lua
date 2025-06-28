require('telescope').setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown()
    }
  }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')

-- keymap
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>fn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
