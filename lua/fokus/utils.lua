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
---@return nil | table<{ zenmode: any, twilight: any }>
function M.get_required_modules()
	local _zmode, zmode = pcall(require, "zen-mode")
	local _twilight, twilight = pcall(require, "twilight")
	if not _zmode or not _twilight then
		return nil
	end
	return { twilight, zmode }
end

return M
