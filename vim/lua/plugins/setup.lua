-- theme
vim.cmd.colorscheme 'solarized'

-- Test
vim.g['test#strategy'] = 'neovim'

-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash',
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
    'python',
    'ruby',
    'sql',
    -- 'swift',
    'toml',
    'typescript',
    'xml',
    'yaml',
  },

  highlight = {
    enable = true,
  },

  autotag = {
    enable = true,
  },
}
