-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup {
  spec = {
    -- navigation
    { 'tmux-plugins/vim-tmux' },
    { 'christoomey/vim-tmux-navigator' },
    { 'tpope/vim-vinegar' },
    { 'justinmk/vim-gtfo' },

    -- theme
    { 'ishan9299/nvim-solarized-lua' },
    { 'nvim-lualine/lualine.nvim', opts = { theme = 'solarized_dark' } },
    { 'nvim-tree/nvim-web-devicons' },
    { 'edkolev/tmuxline.vim' },

    -- treesitter
    { 'nvim-treesitter/nvim-treesitter', lazy = false, build = ':TSUpdate' },

    -- mason
    { 'mason-org/mason.nvim', opts = {} },
    {
      'williamboman/mason-lspconfig.nvim',
      dependencies = {
        'neovim/nvim-lspconfig',
      },
    },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },

    -- finder
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        { 'nvim-telescope/telescope-ui-select.nvim' },
      },
    },

    -- autocomplete
    { 'saghen/blink.cmp', version = '1.*' },

    -- linting and formatting
    { 'dense-analysis/ale' },
    { 'stevearc/conform.nvim' },

    -- git
    { 'tpope/vim-fugitive' },
    { 'lewis6991/gitsigns.nvim' },

    -- keymaps and cmd
    { 'tpope/vim-repeat' },
    { 'tpope/vim-unimpaired' },
    { 'tpope/vim-surround' },
    { 'tpope/vim-abolish' },
    { 'mg979/vim-visual-multi' },

    -- snippet
    { 'L3MON4D3/LuaSnip' },
    { 'windwp/nvim-autopairs' },
    { 'windwp/nvim-ts-autotag' },
    -- { 'mattn/emmet-vim' },

    -- language specifics
    { 'autolyticus/hot-reload.vim' }, -- flutter
    { 'tpope/vim-bundler' },
    { 'ap/vim-css-color' },

    -- test
    {
      'nvim-neotest/neotest',
      dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-lua/plenary.nvim',
        'olimorris/neotest-rspec',
      },
    },

    -- performance
    { 'dstein64/vim-startuptime' },
  },
  install = { colorscheme = { 'solarized' } },
  -- automatically check for plugin updates
  checker = { enabled = false },
}
