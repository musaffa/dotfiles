require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua',
  },
}

require('conform').setup {
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    -- ruby = { 'rubocop' },
    dart = { 'dart_format' },
    lua = { 'stylua' },
  },
}

vim.keymap.set({ 'n', 'v', 'i' }, '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })
