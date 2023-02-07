local M = {}

M.activated = false

M.DEFAULT_OPTS = {
		enabled = true,
		notification = {
				enable = false
		},
		---@type function | nil
		on_focus_leave = nil,
		on_focused_enter = nil,
}

---@param opts table
local function on_focus_mode_enter(opts)
	local callback = function()
		vim.cmd("TwilightEnable")
		if type(opts.on_focused_enter) == "function" then
			opts.on_focused_enter()
		end
		if opts.notification.enable then
			vim.notify("Focus mode enabled", vim.log.levels.INFO)
		end
		M.activated = true
	end
	vim.api.nvim_create_augroup("FocusModeEnter", { clear = true })
	vim.api.nvim_create_autocmd("InsertEnter", {
			group = "FocusModeEnter",
			callback = callback,
	})
end

---@param opts table
local function on_focus_mode_leave(opts)
	local callback = function()
		vim.cmd("TwilightDisable")
		if type(opts.on_focus_leave) == "function" then
			opts.on_focus_leave()
		end
		if opts.notification.enable then
			vim.notify("Focus mode enabled", vim.log.levels.INFO)
		end
		M.activated = false
	end
	vim.api.nvim_create_augroup("FocusModeLeave", { clear = true })
	vim.api.nvim_create_autocmd("InsertLeave", {
			group = "FocusModeLeave",
			callback = callback,
	})
end

---Init depenendencies
---@return nil | table<{zenmode: any, twilight: any}>
local init_requirements = function()
	local _zmode, zmode = pcall(require, "zen-mode")
	local _twilight, twilight = pcall(require, "twilight")
	if not _zmode or not _twilight then
		return nil
	end
	return { twilight, zmode }
end

---@param opts table
---@param on_error function
function M.init_and_start(opts, on_error)
	local mod = init_requirements()

	if not mod then
		local msg = "Please include zenmode and twilight as depenendencies!"
		on_error(msg)
		return
	end

	if opts then
		opts = vim.tbl_extend("force", M.DEFAULT_OPTS, opts or {})
	end

	on_focus_mode_enter(opts)
	on_focus_mode_leave(opts)
end

---@param opts table
function M.setup(opts)
	M.init_and_start(opts, function(err)
		vim.notify(err, vim.log.levels.ERROR)
	end)
end

return M
