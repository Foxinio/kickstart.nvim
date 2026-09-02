local M = {}

function M.file_under_cursor()
	local file = vim.fn.expand('<cfile>')
	local buffer_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	local paths = buffer_dir and { buffer_dir .. '/' .. file, file } or { file }

	for _, path in ipairs(paths) do
		path = vim.fn.fnamemodify(vim.fn.expand(path), ':p')
		if vim.fn.filereadable(path) == 1 then
			require('goto-preview.lib').open_floating_win(vim.uri_from_fname(path), { 1, 0 })
			return
		end
	end

	vim.notify(('No readable file under cursor: %s'):format(file), vim.log.levels.WARN)
end

return M
