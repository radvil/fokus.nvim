local config = require("fokus.config")
local M = {}

M.fokus_active = config.fokus_enabled
M.setup = config.setup

return M
