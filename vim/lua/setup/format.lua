require('mason-tool-installer').setup {
  ensure_installed = {
    'ktfmt',
    'ruff',
    'stylua',
  },
}

local formatters = {
  lua = { 'stylua' },
  dart = { 'dart_format' },
  javascript = { 'prettier' },
  typescript = { 'prettier' },
  python = { 'ruff_format' },
  elixir = { 'mix' },
  kotlin = { 'ktfmt' },
  css = { 'prettier' },
  handlebars = { 'prettier' },
  ['typescript.glimmer'] = { 'prettier' },
  ['javascript.glimmer'] = { 'prettier' },
}

if require('utils.checks').is_ruby_3_plus() then
  formatters.ruby = { 'rubocop' } -- old rubocop has missing params
end

local conform = require 'conform'

conform.setup {
  format_on_save = {
    timeout_ms = 2000,
    lsp_format = 'fallback',
  },
  formatters_by_ft = formatters,
  formatters = {
    ktfmt = {
      args = { '--google-style', '-' },
    },
  },
}

vim.keymap.set({ 'n', 'v', 'i' }, '<leader>f', function()
  conform.format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })
