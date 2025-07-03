require('plugins.codecompanion.fidget-spinner'):init()

require('codecompanion').setup {
  extensions = {
    mcphub = {
      callback = 'mcphub.extensions.codecompanion',
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true,
      },
    },
  },
  strategies = {
    chat = {
      adapter = vim.env.DEFAULT_ADAPTER,
    },
    inline = {
      adapter = vim.env.DEFAULT_ADAPTER,
    },
    cmd = {
      adapter = vim.env.DEFAULT_ADAPTER,
    },
  },
  adapters = {
    gemini = function()
      return require('codecompanion.adapters').extend('gemini', {
        env = {
          api_key = vim.env.GEMINI_API_KEY,
        },
      })
    end,
    ollama = function()
      return require('codecompanion.adapters').extend('ollama', {
        schema = {
          model = {
            default = vim.env.OLLAMA_MODEL,
          },
        },
      })
    end,
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<Leader>ct', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd 'cab cc CodeCompanion'
