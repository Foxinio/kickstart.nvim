-- TODO : Try alternative: https://github.com/coffebar/neovim-project
local M = {
	'rmagatti/auto-session',
}

M.lazy = false

M.init = function()
	vim.opt.sessionoptions:append({ "tabpages", "globals" })
end

---enables autocomplete for opts
---@module "auto-session"
---@type AutoSession.Config
M.opts = {
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
	-- log_level = 'debug',
	auto_restore = false,
	auto_create = false,
	close_unsupported_windows = false,
}

return M
