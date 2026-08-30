local M = {}

function M.find_git_root()
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()

	if current_file == '' then
		current_dir = cwd
	else
		current_dir = vim.fn.fnamemodify(current_file, ':h')
	end

	local git_root =
			vim.fn.systemlist('git -C '
				.. vim.fn.escape(current_dir, ' ')
				.. ' rev-parse --show-toplevel')[1]
	if vim.v.shell_error ~= 0 then
		print 'Not a git repository. Searching on current working directory'
		return cwd
	end

	return git_root
end

function M.live_grep_git_root(opts)
	local git_root = M.find_git_root()
	if git_root then
		require('telescope.builtin').live_grep(vim.tbl_extend('force', opts or {}, {
			search_dirs = { git_root },
		}))
	end
end

function M.current_buffer_fuzzy_find(opts)
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown(vim.tbl_extend('force', {
		winblend = 10,
		previewer = false,
	}, opts or {})))
end

function M.live_grep_open_files(opts)
	require('telescope.builtin').live_grep(vim.tbl_extend('force', {
		grep_open_files = true,
		prompt_title = 'Live Grep in Open Files',
	}, opts or {}))
end

function M.find_file_in_nvim_tree(opts)
	opts = opts or {}

	local picker_attach_mappings = opts.attach_mappings
	local picker_opts = vim.tbl_extend('force', {
		winblend = 10,
		previewer = false,
		prompt_title = 'Select File',
		cwd = require('nvim-tree.core').get_cwd(),
	}, opts)
	picker_opts.attach_mappings = function(prompt_bufnr, map)
		local function select_file()
			require('telescope.actions').close(prompt_bufnr)

			local entry = require('telescope.actions.state').get_selected_entry()
			local path = entry and (entry.path or entry[1])
			if not path or path == '' then
				return
			end

			require('nvim-tree.api').tree.find_file({
				open = true,
				focus = true,
				buf = path,
			})
		end

		map('i', '<CR>', select_file)
		map('n', '<CR>', select_file)

		if picker_attach_mappings then
			return picker_attach_mappings(prompt_bufnr, map)
		end

		return true
	end

	require('telescope.builtin').find_files(require('telescope.themes').get_dropdown(picker_opts))
end

return M
