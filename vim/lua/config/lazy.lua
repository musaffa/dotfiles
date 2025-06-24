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
    { 'editorconfig/editorconfig-vim' },
    { 'nvim-lua/plenary.nvim' },
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

    -- fuzzy finder
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope.nvim' },

    -- git
    { 'tpope/vim-fugitive' },
    { 'lewis6991/gitsigns.nvim' },

    -- auto pair
    { 'windwp/nvim-autopairs' },
    { 'windwp/nvim-ts-autotag' },

    -- tim pope
    { 'tpope/vim-unimpaired' },
    { 'tpope/vim-surround' },

    -- Comment
    { 'numToStr/Comment.nvim' },

    -- snippet
    { 'mattn/emmet-vim' },
    { 'L3MON4D3/LuaSnip' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- selection and replace
    { 'terryma/vim-multiple-cursors' },
    { 'tpope/vim-abolish' },

    -- test
    { 'janko-m/vim-test' },
    { 'benmills/vimux' },

    -- linting and formatting
    { 'w0rp/ale' },

    -- language specifics
    { 'reisub0/hot-reload.vim' },
    { 'tpope/vim-bundler' },
    { 'ap/vim-css-color' },

    -- miscelleneous
    { 'metakirby5/codi.vim' },

    -- performance
    { 'dstein64/vim-startuptime' },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'solarized' } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
