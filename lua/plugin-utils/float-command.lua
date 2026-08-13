local M = {}

local state = {
	buf = nil,
	win = nil,
	keep_next_telescope = false,
}

function M.cleanup()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		pcall(vim.api.nvim_win_close, state.win, true)
	end
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
	end
	state.buf = nil
	state.win = nil
end

local function ensure_cleanup_autocmd()
	if vim.g.float_command_cleanup_autocmd then
		return
	end

	vim.g.float_command_cleanup_autocmd = true
	vim.api.nvim_create_autocmd("User", {
		pattern = "TelescopeFindPre",
		callback = function()
			if state.keep_next_telescope then
				state.keep_next_telescope = false
				return
			end
			M.cleanup()
		end,
	})
end

function M.open(command)
	ensure_cleanup_autocmd()
	M.cleanup()

	local original_win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.9),
		height = math.floor(vim.o.lines * 0.8),
		row = math.floor(vim.o.lines * 0.1),
		col = math.floor(vim.o.columns * 0.05),
		border = "rounded",
	})

	local ok, err = pcall(vim.cmd, command)
	if not ok then
		M.cleanup()
		if vim.api.nvim_win_is_valid(original_win) then
			vim.api.nvim_set_current_win(original_win)
		end
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	state.win = vim.api.nvim_get_current_win()
	state.buf = vim.api.nvim_win_get_buf(state.win)
	vim.bo[state.buf].bufhidden = "hide"

	state.keep_next_telescope = true
	require("telescope.builtin").current_buffer_fuzzy_find({
		bufnr = state.buf,
		prompt_title = command,
	})
end

function M.resume()
	ensure_cleanup_autocmd()
	state.keep_next_telescope = true
	require("telescope.builtin").resume()
end

return M
