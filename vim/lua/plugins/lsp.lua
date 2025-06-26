require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'ember'
  }
})

-- ruby
local ruby = tonumber(vim.fn.system("ruby -v"):match("ruby (%d+)"))

if ruby and ruby >= 3 then
  vim.lsp.enable('ruby_lsp')
end
