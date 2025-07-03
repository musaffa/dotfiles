local M = {}

function M.is_ruby_3_plus()
  local ruby = tonumber(vim.fn.system('ruby -v'):match 'ruby (%d+)')
  return ruby and ruby >= 3
end

return M
