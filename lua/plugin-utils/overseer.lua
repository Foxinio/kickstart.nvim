local M = {}

function M.clear_list()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ include_ephemeral = true })

	for _, task in ipairs(tasks) do
		task:dispose(true)
	end

	vim.notify(string.format("Disposed %d Overseer tasks", #tasks), vim.log.levels.INFO)
end

return M
