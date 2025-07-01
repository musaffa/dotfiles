-- theme
vim.cmd.colorscheme 'solarized'

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
    'markdown',
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
