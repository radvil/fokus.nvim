local M = {}
local utils = require("fokus.utils")

---@class FokusState
M.state = {
  ---@type FokusOptions | nil
  opts = nil,
  is_enabled = true,
  view = nil,
}

local o = function()
  return M.state.opts
end

function M.get_view()
  return M.state.view
end

---@return boolean
function M.is_view_active()
  return M.state.view.enabled
end

---@class FokusEventNames
local fokus_event_names = {
  InsertEnter = "FokusEnter",
  InsertLeave = "FokusLeave",
}

---check whether current buffer is included in the blacklist config
---@return boolean
local function is_blacklisted()
  return utils.buffer_excluded(o().exclude_filetypes)
end

---call after view enter
local function post_enter()
  if o().hooks and type(o().hooks.post_enter) == "function" then
    o().hooks.post_enter()
    vim.print(o().hooks)
  end
end

---call after view leave
local function post_leave()
  if o().hooks and type(o().hooks.post_leave) == "function" then
    o().hooks.post_leave()
    vim.print(o().hooks)
  end
end

---make sure to have twilight and zenmode has been initialized
---throw error and exit if not fulfilled
local function ensure_dependencies()
  if not utils.has_required_deps() then
    local msg = "❌ please include zenmode and twilight as depenendencies!"
    local level = vim.log.levels.ERROR
    utils.notify(msg, level)
    error(msg, level)
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

---enable twilight view
function M.enter()
  if not is_blacklisted() and M.is_enabled then
    M.get_view().enable()
    post_enter()
  end
end

---disable twilight view
function M.leave()
  if not is_blacklisted() and M.is_enabled then
    M.get_view().disable()
    post_leave()
  end
end

local function register_toggle()
  vim.api.nvim_create_user_command("FokusToggle", M.toggle, {
    desc = "Toggle (enable/disable)",
  })
end

-- toggle enable
function M.toggle()
  M.is_enabled = not M.is_enabled
  local msg = M.is_enabled and "😎 Enabled" or "👀 Disabled"
  local level = M.is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
  utils.notify(msg, level)
end

---setup twilight view
---@param opts FokusOptions
function M.setup(opts)
  ensure_dependencies()
  M.state.opts = opts
  M.state.view = require("twilight.view")
  on_fokus("InsertEnter", M.enter)
  on_fokus("InsertLeave", M.leave)
  register_toggle()
end

return M
