-- colorscheme
vim.cmd('colorscheme solarized')

-- lualine
require('lualine').setup {
  options = { theme = 'solarized_dark' }
}
