-- If you don't understand a setting in here, just type ':h setting'.

-- Set Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

vim.opt.linebreak = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = '81'

-- Set Clipboard
vim.opt.clipboard = 'unnamedplus'

-- TAB settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Window settings
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Theme
vim.opt.termguicolors = true

-- Backup settings
vim.opt.writebackup = false

-- Vim diff split
vim.opt.diffopt:append('vertical')

-- plug manager
require('config.lazy')

-- theme
vim.cmd('colorscheme solarized')

--
-- lualine
require('lualine').setup {
  options = { theme = 'solarized_dark' }
}

--
-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash',
    'c',
    'css',
    'dart',
    'dockerfile',
    'glimmer',
    'go',
    'html',
    'java',
    'javascript',
    'json',
    'kotlin',
    'lua',
    'python',
    'ruby',
    -- 'sql',
    -- 'swift',
    'toml',
    'typescript',
    -- 'xml',
    'vim',
    'yaml'
  },

  highlight = {
    enable = true
  },

  autotag = {
    enable = true
  }
}

--
-- mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    -- 'solargraph',
    'ts_ls',
    'ember'
  }
})

--
-- cmp
local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'text',
      menu = ({
        buffer = "[Buffer]",
        path = "[Path]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
      })
    }),
  },
  experimental = {
    native_menu = false,
    ghost_text = true
  }
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

--
-- lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.format, bufopts)
end

local nvim_lsp = require('lspconfig')

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

local servers = {
  'dartls',
  'ember',
  -- 'solargraph',
  'ts_ls'
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities
  }
end

--
-- autopairs
local npairs = require('nvim-autopairs')
npairs.setup {
  check_ts = true
}
npairs.add_rules(require 'nvim-autopairs.rules.endwise-ruby')

--
-- gitsigns
require('gitsigns').setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
        opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Navigation
    map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
    map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
    map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
    map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
    map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
    map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
    map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
    map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
    map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>')

    -- Text object
    map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

require('Comment').setup()

-- ALE
vim.g.ale_ruby_rubocop_executable = 'bundle'

-- Telescope
vim.keymap.set('n', '<leader>f', '<cmd>lua require("telescope.builtin").find_files()<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>s', '<cmd>lua require("telescope.builtin").live_grep()<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fb','b <cmd>lua require("telescope.builtin").buffers()<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fh','h <cmd>lua require("telescope.builtin").help_tags()<cr>', { noremap=true, silent=true })

-- Vim test mappings
vim.keymap.set('n', '<leader>t', ':TestNearest<CR>', { silent=true })
vim.keymap.set('n', '<leader>T', ':TestFile<CR>', { silent=true })
vim.keymap.set('n', '<leader>a', ':TestSuite<CR>', { silent=true })
vim.keymap.set('n', '<leader>l', ':TestLast<CR>', { silent=true })
vim.keymap.set('n', '<leader>g', ':TestVisit<CR>', { silent=true })

-- Neovim terminal mappings
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', { noremap=true })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { noremap=true })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { noremap=true })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { noremap=true })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { noremap=true })

-- Map the missing Y yank
vim.keymap.set('n', 'Y', 'y$', { noremap=true, silent=true })

-- free c-l from netrw's plug mapping
vim.keymap.set('n', '<leader><leader><leader>l', '<Plug>NetrwRefresh')

-- Prettify Json files
vim.keymap.set('n', '<Leader>fj', ':%!jq .<CR>', { noremap=true })
