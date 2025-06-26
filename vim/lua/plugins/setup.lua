-- theme
vim.cmd.colorscheme('solarized')

-- Test
vim.g['test#strategy'] = 'neovim'

-- ALE
vim.g.ale_ruby_rubocop_executable = 'bundle'

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

require('telescope').load_extension('fzf')
