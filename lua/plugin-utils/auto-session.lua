local M = {}

local function has_real_file(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	local stat = name ~= "" and vim.uv.fs_stat(name)
	return stat and stat.type == "file"
end

function M.open_git_tab()
	local cwd = vim.fn.getcwd()
	local git_root = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })[1]
	local cwd_real = vim.uv.fs_realpath(cwd)
	local git_root_real = git_root and vim.uv.fs_realpath(git_root)
	local is_git_root = vim.v.shell_error == 0 and git_root_real == cwd_real
	local current_tab = vim.api.nvim_get_current_tabpage()

	if not is_git_root then
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "fugitive" then
					pcall(vim.api.nvim_set_current_tabpage, tab)
					pcall(vim.cmd, "tabclose")
					break
				end
			end
		end
		if vim.api.nvim_tabpage_is_valid(current_tab) then
			vim.api.nvim_set_current_tabpage(current_tab)
		end
		return
	end

	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file ~= "" then
		local file_root = vim.fn.systemlist({ "git", "-C", vim.fn.fnamemodify(current_file, ":h"), "rev-parse", "--show-toplevel" })[1]
		if vim.v.shell_error ~= 0 or vim.uv.fs_realpath(file_root) ~= cwd_real then
			return
		end
	end

	local ok, tab_name = pcall(require, "tabby.feature.tab_name")
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		if ok and tab_name.get_raw(tab) == "GIT" then
			return
		end

		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].filetype == "fugitive" then
				return
			end
		end
	end

	vim.cmd("tab Git")
	vim.cmd("Tabby rename_tab GIT")
	if vim.api.nvim_tabpage_is_valid(current_tab) then
		vim.api.nvim_set_current_tabpage(current_tab)
	end
end

function M.clean_session_buffers()
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			if vim.api.nvim_win_get_config(win).relative == "" and not has_real_file(vim.api.nvim_win_get_buf(win)) then
				if #vim.api.nvim_tabpage_list_wins(tab) > 1 then
					pcall(vim.api.nvim_win_close, win, true)
				elseif #vim.api.nvim_list_tabpages() > 1 then
					pcall(vim.api.nvim_set_current_tabpage, tab)
					pcall(vim.cmd, "tabclose")
				end
			end
		end
	end

	local visible = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		visible[buf] = true
		if not has_real_file(buf) then
			return false
		end
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and not visible[buf] then
			pcall(vim.api.nvim_buf_delete, buf, { force = not has_real_file(buf) })
		end
	end

	return true
end

return M
