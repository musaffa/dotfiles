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
    -- library
    { 'nvim-lua/plenary.nvim' },

    -- navigation
    { 'tmux-plugins/vim-tmux' },
    { 'christoomey/vim-tmux-navigator' },
    { 'tpope/vim-vinegar' },
    { 'justinmk/vim-gtfo' },

    -- ui
    {
      'ishan9299/nvim-solarized-lua',
      config = function()
        vim.cmd.colorscheme 'solarized'
      end,
    },
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-lualine/lualine.nvim', opts = { theme = 'solarized_dark' } },
    { 'edkolev/tmuxline.vim' },
    { 'j-hui/fidget.nvim' },

    -- syntax
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      branch = 'master',
      build = ':TSUpdate',
      dependencies = {
        {
          'OXY2DEV/markview.nvim',
          opts = {
            preview = {
              filetypes = { 'markdown', 'codecompanion' },
              ignore_buftypes = {},
            },
          },
        },
      },
    },

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
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        { 'nvim-telescope/telescope-ui-select.nvim' },
      },
    },

    -- snippets
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      dependencies = {
        { 'rafamadriz/friendly-snippets' },
      },
    },
    { 'windwp/nvim-autopairs' },
    { 'windwp/nvim-ts-autotag', opts = {} },

    -- autocomplete
    { 'saghen/blink.cmp', version = '1.*' },

    -- linting and formatting
    {
      'dense-analysis/ale',
      config = function()
        vim.g.ale_ruby_rubocop_executable = 'bundle'
      end,
    },
    { 'stevearc/conform.nvim' },

    -- assistant
    { 'olimorris/codecompanion.nvim' },
    { 'zbirenbaum/copilot.lua' },

    -- git
    { 'tpope/vim-fugitive' },
    { 'lewis6991/gitsigns.nvim' },

    -- keymaps and cmd
    { 'tpope/vim-repeat' },
    { 'tpope/vim-unimpaired' },
    { 'tpope/vim-surround' },
    { 'tpope/vim-abolish' },
    { 'mg979/vim-visual-multi' },

    -- language specifics
    { 'autolyticus/hot-reload.vim' }, -- flutter
    { 'tpope/vim-bundler' },
    { 'ap/vim-css-color' },

    -- test
    { 'janko-m/vim-test' },
    -- {
    --   'nvim-neotest/neotest',
    --   dependencies = {
    --     'nvim-neotest/nvim-nio',
    --     'olimorris/neotest-rspec',
    --   },
    -- },

    -- performance
    { 'dstein64/vim-startuptime' },
  },
  install = { colorscheme = { 'solarized' } },
  -- automatically check for plugin updates
  checker = { enabled = false },
}
