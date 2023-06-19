local M = {}

---@param msg string
---@param level? number
function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, {
    title = "fokus.nvim",
  })
end

---Init depenendencies
---@return nil | boolean
function M.has_required_deps()
  local _zmode, _ = pcall(require, "zen-mode")
  local _twilight, _ = pcall(require, "twilight")
  if not _zmode or not _twilight then
    return false
  else
    return true
  end
end

---find first index of value given
---@param tbl table
---@return boolean
function M.buffer_excluded(tbl)
  if type(tbl) ~= "table" then
    error("table expected, got " .. type(tbl), 2)
  end
  local ret = false
  for _, v in pairs(tbl) do
    if vim.bo.ft == v then
      ret = true
      break
    end
  end
  return ret
end

return M
