require('conform').setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    -- ruby = { 'rubocop' },
    dart = { 'dart_format' },
  }
})

vim.keymap.set({'n', 'v', 'i'}, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })
