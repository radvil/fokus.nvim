local M = {}

---@class FokusOptions
local defaults = {
  exclude_filetypes = {},
  ---@class FokusHookOptions
  hooks = {
    ---@type function | nil
    post_enable = nil,
    ---@type function | nil
    post_disable = nil,
    ---@type function | nil
    post_enter = nil,
    ---@type function | nil
    post_leave = nil,
  },
}

---@type boolean
M.loaded = false

---@param opts FokusOptions | nil
function M.setup(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  require("fokus.view").setup(opts)
  M.loaded = true
end

M.setup()

return M
