require('blink.cmp').setup({
  completion = {
    menu = {
      draw = {
        columns = {
          { 'label', 'label_description', gap = 1 },
          { 'kind' },
          { 'source_name' }
        }
      }
    }
  },

  cmdline = {
    completion = { menu = { auto_show = true } },
    sources = function()
      local type = vim.fn.getcmdtype()
      -- Search forward and backward
      if type == '/' or type == '?' then return { 'buffer' } end
      -- Commands
      if type == ':' or type == '@' then return { 'cmdline', 'buffer' } end
      return {}
    end,
  }
})
