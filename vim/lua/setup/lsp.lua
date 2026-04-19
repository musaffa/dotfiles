require('mason-lspconfig').setup {
  ensure_installed = {
    'expert',
    'kotlin_lsp',
    'lua_ls',
    'pyright',
    'ts_ls',
  },
}

vim.lsp.config('ts_ls', {
  filetypes = {
    'typescript',
    'javascript',
    'typescript.glimmer',
    'javascript.glimmer',
  },
  get_language_id = function(_, filetype)
    local map = {
      ['typescript.glimmer'] = 'typescript',
      ['javascript.glimmer'] = 'javascript',
    }
    return map[filetype] or filetype
  end,
  before_init = function(_, config)
    local plugin_path = config.root_dir .. '/node_modules/@glint/tsserver-plugin'
    if vim.fn.isdirectory(plugin_path) == 1 then
      config.init_options = config.init_options or {}
      config.init_options.plugins = config.init_options.plugins or {}
      table.insert(config.init_options.plugins, {
        name = '@glint/tsserver-plugin',
        location = plugin_path,
      })
    end
  end,
})

-- ruby
if require('utils.checks').is_ruby_3_plus() then
  vim.lsp.enable 'ruby_lsp' -- old ruby does not support ruby-lsp
end

-- Keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local builtin = require 'telescope.builtin'

    map('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
    map('gr', builtin.lsp_references, '[G]oto [R]eferences')
    map('gi', builtin.lsp_implementations, '[G]oto [I]mplementation')
    map('gt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
    map('gn', vim.lsp.buf.rename, 'Re[n]ame')
  end,
})
