require('luasnip').filetype_extend('handlebars', { 'html' })

-- friendly snippets
require('luasnip.loaders.from_vscode').lazy_load()

-- autopairs
local npairs = require 'nvim-autopairs'
npairs.setup { check_ts = true }
npairs.add_rules(require 'nvim-autopairs.rules.endwise-ruby')
