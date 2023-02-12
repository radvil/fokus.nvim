local M = {}
local utils = require("fokus.utils")

--- @class FokusOptions
local defaults = {
  enabled = true,
  notification = {
    enabled = false,
  },
  exclude_filetypes = {}, -- TODO: configure this
  ---@type function | nil
  on_fokus_leave = nil,
  ---@type function | nil
  on_fokus_enter = nil,
}

---@type FokusOptions
M.options = {}

---@type boolean
M.fokus_enabled = false

function M.fokus_enter()
  if not not utils.find_findex(M.options.exclude_filetypes, vim.bo.ft) then
    return
  end
  vim.cmd("TwilightEnable")
  if type(M.options.on_fokus_enter) == "function" then
    M.options.on_fokus_enter()
  end
  if M.options.notification.enabled then
    utils.notify("😎 fokus enabled")
  end
  M.fokus_enabled = true
end

function M.fokus_leave()
  if not not utils.find_findex(M.options.exclude_filetypes, vim.bo.ft) then
    return
  end
  vim.cmd("TwilightDisable")
  if type(M.options.on_fokus_leave) == "function" then
    M.options.on_fokus_leave()
  end
  if M.options.notification.enabled then
    utils.notify("👀 fokus disabled")
  end
  M.fokus_enabled = false
end

---@param options FokusOptions | nil
function M.setup(options)
  local mod = require("fokus.utils").get_required_modules()
  if mod == nil then
    utils.notify("❌ please include zenmode and twilight as depenendencies!", vim.log.levels.ERROR)
    return
  end
  M.options = vim.tbl_extend("force", defaults, options or {})
  require("fokus.autocmds").on_fokus("InsertEnter", M.fokus_enter)
  require("fokus.autocmds").on_fokus("InsertLeave", M.fokus_leave)
end

M.setup()

return M
