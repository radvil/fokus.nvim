local M = {}

M.groups = {
		InsertEnter = "FokusEnter",
		InsertLeave = "FokusLeave"
}

---Register autocommands on insert enter or leave
---@param event_name "InsertEnter" | "InsertLeave"
---@param callback function
function M.on_fokus(event_name, callback)
	local group = M.groups[event_name]
	vim.api.nvim_create_augroup(group, { clear = true })
	vim.api.nvim_create_autocmd(event_name, {
			callback = callback,
			group = group,
	})
end

return M
