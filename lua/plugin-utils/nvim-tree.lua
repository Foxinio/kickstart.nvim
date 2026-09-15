local M = {}

function M.find_current_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(bufnr)

	if file == "" then
		vim.notify("Cannot find current buffer in nvim-tree: it has no file path", vim.log.levels.INFO)
		return
	end

	if vim.fn.filereadable(file) == 0 then
		vim.notify("Cannot find current buffer in nvim-tree: file does not exist or is not readable: " .. file,
			vim.log.levels.INFO)
		return
	end

	require("nvim-tree.api").tree.find_file({
		buf = bufnr,
		open = true,
		focus = true,
		update_root = true,
	})
end

return M
