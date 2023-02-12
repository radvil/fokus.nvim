local M = {}

function M.notify(message, lvl)
  local status, notify_nvim = pcall(require, "notify.nvim")
  if status then
    vim.notify = notify_nvim
  end
  lvl = lvl == nil and vim.log.levels.INFO or lvl
  vim.notify(message, lvl)
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

---merge default opts with user provided config
---@param defaults FokusOptions
---@param changes FokusOptions | nil
---@return any
function M.merge_options(defaults, changes)
  changes = changes or {}
  if changes and type(changes.view) == "table" then
    defaults.view = vim.tbl_deep_extend("force", defaults.view, changes.view)
  end
  return vim.tbl_deep_extend("force", defaults, changes)
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
