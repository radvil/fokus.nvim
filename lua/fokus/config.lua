local M = {}

---@class FokusOptions
M.options = {
  ---@class FokusViewOptions
  view = {
    notify_status_change = false,
    blacklists_filetypes = {},
    ---@type function | nil
    on_fokus_leave = nil,
    ---@type function | nil
    on_fokus_enter = nil,
  },
}

---@type boolean
M.loaded = false

---@param opts FokusOptions | nil
function M.setup(opts)
  M.options = require("fokus.utils").merge_options(M.options, opts)
  require("fokus.view").setup(M.options.view)
  M.loaded = true
end

M.setup()

return M
