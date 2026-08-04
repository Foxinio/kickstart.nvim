-- TODO : Try alternative: https://github.com/coffebar/neovim-project
local M = {
	'rmagatti/auto-session',
}

M.lazy = false

M.init = function()
	vim.opt.sessionoptions:append({ "tabpages", "globals" })
	vim.opt.sessionoptions:remove("buffers")
end

local function open_git_tab()
	local cwd = vim.fn.getcwd()
	local git_root = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })[1]
	local is_git_root = vim.v.shell_error == 0 and vim.uv.fs_realpath(git_root) == vim.uv.fs_realpath(cwd)
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

	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
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

---enables autocomplete for opts
---@module "auto-session"
---@type AutoSession.Config
M.opts = {
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
	-- log_level = 'debug',
	auto_restore = true,
	auto_create = true,
	close_filetypes_on_save = {
		"checkhealth",
		"NvimTree",
		"NvimTreeFilter",
		"OverseerList",
		"OverseerOutput",
		"OverseerForm",
		"fugitive",
		"fugitiveblame",
	},
	close_unsupported_windows = false,
	post_restore_cmds = {
		function()
			vim.schedule(open_git_tab)
		end,
	},
	no_restore_cmds = {
		function()
			vim.schedule(open_git_tab)
		end,
	},
}

return M
