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

-- Keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local builtin = require('telescope.builtin')

    map('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
    map('gr', builtin.lsp_references, '[G]oto [R]eferences')
    map('gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
    map('gt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
    map('gn', vim.lsp.buf.rename, 'Re[n]ame')
  end
})
