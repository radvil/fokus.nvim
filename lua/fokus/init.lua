---@class FokusNvim
local M = {}

M.is_activated = require("fokus.view").is_view_active
M.setup = require("fokus.config").setup

return M
