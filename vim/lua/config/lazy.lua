-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { 'tpope/vim-repeat' },

    -- lsp
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'neovim/nvim-lspconfig' },

    -- autocomplete
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/nvim-cmp' },
    { 'onsails/lspkind.nvim' },

    -- treesitter
    { 'nvim-treesitter/nvim-treesitter', lazy = false, build = ':TSUpdate' },

    -- tmux
    { 'tmux-plugins/vim-tmux' },
    { 'christoomey/vim-tmux-navigator' },

    -- theme
    { 'ishan9299/nvim-solarized-lua' },
    { 'nvim-lualine/lualine.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
    { 'edkolev/tmuxline.vim' },

    -- file navigation
    { 'tpope/vim-vinegar' },
    { 'justinmk/vim-gtfo' },

    -- finder
    { 'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

    -- git
    { 'tpope/vim-fugitive' },
    { 'lewis6991/gitsigns.nvim' },

    -- auto pair
    { 'windwp/nvim-autopairs' },
    { 'windwp/nvim-ts-autotag' },

    -- tim pope
    { 'tpope/vim-unimpaired' },
    { 'tpope/vim-surround' },

    -- snippet
    { 'mattn/emmet-vim' },
    { 'L3MON4D3/LuaSnip' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- selection and replace
    { 'mg979/vim-visual-multi' },
    { 'tpope/vim-abolish' },

    -- test
    { 'janko-m/vim-test' },

    -- linting and formatting
    { 'dense-analysis/ale' },

    -- language specifics
    { 'autolyticus/hot-reload.vim' },
    { 'tpope/vim-bundler' },
    { 'ap/vim-css-color' },

    -- performance
    { 'dstein64/vim-startuptime' },
  },
  install = { colorscheme = { 'solarized' } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
