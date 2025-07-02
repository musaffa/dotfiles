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
  display = {
    action_palette = {
      provider = 'telescope',
    },
  },
  strategies = {
    chat = {
      adapter = 'gemini',
    },
    inline = {
      adapter = 'gemini',
    },
    cmd = {
      adapter = 'gemini',
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
  },
}

local diff = require 'mini.diff'
diff.setup { source = diff.gen_source.none() }

vim.keymap.set({ 'n', 'v' }, '<leader>cs', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<Leader>ct', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
vim.keymap.set('v', '<Leader>ca', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd [[cab cc CodeCompanion]]
