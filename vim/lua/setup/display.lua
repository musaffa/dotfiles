-- treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'bash',
    'css',
    'dart',
    'dockerfile',
    'glimmer',
    'glimmer_javascript',
    'glimmer_typescript',
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
}
