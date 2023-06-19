local M = {}
local utils = require("fokus.utils")

M.is_enabled = true

---twilight.view module
---@type nil | any
local twilight_view = nil

---@type FokusViewOptions
local view_opts = {}

---@class FokusEventNames
local fokus_event_names = {
  InsertEnter = "FokusEnter",
  InsertLeave = "FokusLeave",
}

---check whether current buffer is included in the blacklist config
---@return boolean
local function is_blacklisted()
  return utils.buffer_excluded(view_opts.blacklists_filetypes)
end

---after fokus enter react to custom user's view options
local function post_enter()
  if type(view_opts.on_fokus_enter) == "function" then
    view_opts.on_fokus_enter()
  end
  if view_opts.notify_status_change then
    utils.notify("😎 fokus enabled")
  end
end

---after fokus leave react to custom user's view options
local function post_leave()
  if type(view_opts.on_fokus_leave) == "function" then
    view_opts.on_fokus_leave()
  end
  if view_opts.notify_status_change then
    utils.notify("👀 fokus disabled")
  end
end

---make sure to have twilight and zenmode has been initialized
---throw error and exit if not fulfilled
local function ensture_deps_installed()
  if not utils.has_required_deps() then
    local msg = "❌ please include zenmode and twilight as depenendencies!"
    local lvl = vim.log.levels.ERROR
    utils.notify(msg, lvl)
    error(msg, lvl)
  end
end

---Register autocommands on insert enter or leave
---@param event_name "InsertEnter" | "InsertLeave"
---@param callback function
local function on_fokus(event_name, callback)
  local group = fokus_event_names[event_name]
  vim.api.nvim_create_augroup(group, { clear = true })
  vim.api.nvim_create_autocmd(event_name, {
    callback = callback,
    group = group,
  })
end

---@return boolean
function M.is_fokus_active()
  return twilight_view.enabled
end

---enable twilight view
function M.enter()
  if not is_blacklisted() and M.is_enabled then
    twilight_view.enable()
    post_enter()
  end
end

---disable twilight view
function M.leave()
  if not is_blacklisted() and M.is_enabled then
    twilight_view.disable()
    post_leave()
  end
end

local function register_toggle()
  vim.api.nvim_create_user_command("FokusToggle", M.toggle, {
    desc = "Fokus » Toggle (enable/disable)",
  })
end

-- toggle enable
function M.toggle()
  M.is_enabled = not M.is_enabled
  local status = M.is_enabled and "enabled" or "disabled"
  local log_lvl = M.is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
  utils.notify("Fokus » " .. status, log_lvl)
end

---setup twilight view
---@param options FokusViewOptions
function M.setup(options)
  view_opts = options or {}
  ensture_deps_installed()
  twilight_view = require("twilight.view")
  on_fokus("InsertEnter", M.enter)
  on_fokus("InsertLeave", M.leave)
  register_toggle()
end

-- TODO: better to restructure view options based on the originals ?
-- for a better maintanance later

return M
