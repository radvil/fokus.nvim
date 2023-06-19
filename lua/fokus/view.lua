local M = {}
local utils = require("fokus.utils")

---@class FokusState
local state = {
  ---@type FokusOptions | nil
  opts = nil,
  is_enabled = true,
  view = nil,
}

function M.get_state()
  return state
end

---@return boolean
function M.is_view_active()
  return state.view.enabled
end

---@class FokusEventNames
local event_names = {
  InsertEnter = "FokusEnter",
  InsertLeave = "FokusLeave",
}

---check whether current buffer is included in the blacklist config
---@return boolean
local function is_blacklisted()
  return utils.buffer_excluded(state.opts.exclude_filetypes)
end

---make sure to have twilight and zenmode has been initialized
---throw error and exit if not fulfilled
local function ensure_dependencies()
  if not utils.has_required_deps() then
    local msg = "❌ please include zenmode and twilight as depenendencies!"
    local level = vim.log.levels.ERROR
    utils.notify(msg, level)
    error(msg, level)
  else
    state.view = require("twilight.view")
  end
end

---Register autocommands on insert enter or leave
---@param event_name "InsertEnter" | "InsertLeave"
---@param callback function
local function on_fokus(event_name, callback)
  local group = event_names[event_name]
  vim.api.nvim_create_augroup(group, { clear = true })
  vim.api.nvim_create_autocmd(event_name, {
    callback = callback,
    group = group,
  })
end

---enable twilight view
function M.enter()
  if not is_blacklisted() and state.is_enabled then
    state.view.enable()
  end
end

---disable twilight view
function M.leave()
  if not is_blacklisted() and state.is_enabled then
    state.view.disable()
  end
end

local function register_toggle()
  vim.api.nvim_create_user_command("FokusToggle", M.toggle, {
    desc = "Toggle (enable/disable)",
  })
end

-- toggle enable
function M.toggle()
  state.is_enabled = not state.is_enabled
  if state.opts.hooks then
    local next = state.is_enabled and "post_enable" or "post_disable"
    if state.opts.hooks[next] then
      state.opts.hooks[next]()
    end
  end
  if state.opts.notify.enabled then
    local msg = state.is_enabled and "😎 Enabled" or "👀 Disabled"
    local level = state.is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
    utils.notify(msg, level)
  end
end

---setup twilight view
---@param opts FokusOptions
function M.setup(opts)
  state.opts = opts
  ensure_dependencies()
  on_fokus("InsertEnter", M.enter)
  on_fokus("InsertLeave", M.leave)
  register_toggle()
end

return M
