local M = {}

local function open_float(buf)
	return require("overseer.layout").open_fullscreen_float(buf)
end

function M.open(command)
	local buf = vim.api.nvim_create_buf(false, true)
	local original_win = vim.api.nvim_get_current_win()
	open_float(buf)

	local ok, err = pcall(vim.cmd, command)
	if not ok then
		if vim.api.nvim_win_is_valid(original_win) then
			vim.api.nvim_set_current_win(original_win)
		end
		vim.notify(err, vim.log.levels.ERROR)
		return
	end
end

function M.open_telescope_selection(prompt_bufnr)
	local action_state = require("telescope.actions.state")
	local entry = action_state.get_selected_entry()
	if not entry then
		return
	end

	require("telescope.pickers").on_close_prompt(prompt_bufnr)

	local bufnr = entry.bufnr
	if bufnr then
		if not vim.bo[bufnr].buflisted then
			vim.bo[bufnr].buflisted = true
		end
		open_float(bufnr)
	else
		local path = entry.path or entry.filename or entry.value
		if type(path) ~= "string" or path == "" then
			return
		end

		open_float(vim.api.nvim_create_buf(false, true))
		vim.cmd.edit(vim.fn.fnameescape(path))
	end

	local row = entry.row or entry.lnum
	if row then
		pcall(vim.api.nvim_win_set_cursor, 0, { row, math.max((entry.col or 1) - 1, 0) })
	end
end

function M.resume()
	require("telescope.builtin").resume()
end

return M
