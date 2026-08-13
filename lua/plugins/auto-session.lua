-- TODO : Try alternative: https://github.com/coffebar/neovim-project
local M = {
	'rmagatti/auto-session',
}

M.lazy = false

M.init = function()
	vim.opt.sessionoptions:append({ "tabpages", "globals" })
	vim.opt.sessionoptions:remove("buffers")
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
	pre_save_cmds = {
		function()
			return require("plugin-utils.auto-session").clean_session_buffers()
		end,
	},
	post_restore_cmds = {
		function()
			vim.schedule(require("plugin-utils.auto-session").open_git_tab)
		end,
	},
	no_restore_cmds = {
		function()
			vim.schedule(require("plugin-utils.auto-session").open_git_tab)
		end,
	},
}

return M
