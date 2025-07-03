require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua',
  },
}

local formatters = {
  lua = { 'stylua' },
  dart = { 'dart_format' },
  javascript = { 'prettier' },
  handlebars = { 'prettier' },
  css = { 'prettier' },
}

local ruby = tonumber(vim.fn.system('ruby -v'):match 'ruby (%d+)')

if ruby and ruby >= 3 then
  formatters.ruby = { 'rubocop' } -- old rubocop has missing params
end

local conform = require 'conform'

conform.setup {
  format_on_save = {
    timeout_ms = 2000,
    lsp_format = 'fallback',
  },
  formatters_by_ft = formatters,
}

vim.keymap.set({ 'n', 'v', 'i' }, '<leader>f', function()
  conform.format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })
