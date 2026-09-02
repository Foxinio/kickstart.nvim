local M = {}

function M.find_current_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(bufnr)

	if file == "" or not vim.fs.relpath(vim.fn.getcwd(), file) then
		vim.notify("Current file is not under cwd", vim.log.levels.INFO)
		return
	end

	require("nvim-tree.api").tree.find_file({
		buf = bufnr,
		open = true,
		focus = true,
		update_root = false,
	})
end

return M
