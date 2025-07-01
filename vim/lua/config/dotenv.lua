-- populate vim.env with .env variables
local file, ioerr = io.open(vim.fn.stdpath 'config' .. '/.env', 'r')

if not file then
  vim.notify('Could not open .env file: ' .. ioerr, vim.log.levels.WARN)
  return
end

local ok, err = pcall(function()
  for line in file:lines() do
    local key, value = line:match '^([%w_]+)%s*=%s*(.+)$'
    if key and value then
      -- Remove optional quotes around the value
      value = value:gsub([["(.-)"]], '%1')
      vim.env[key] = value
    end
  end
end)

file:close()

if not ok then
  vim.notify('Error loading .env: ' .. err, vim.log.levels.ERROR)
end
