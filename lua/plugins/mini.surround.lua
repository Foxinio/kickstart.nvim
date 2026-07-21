-- Surround actions.
-- https://github.com/echasnovski/mini.surround

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.surround.lua

local M = {
	"echasnovski/mini.surround",
	version = "v0.17.0",
}
M.enabled = false

M.opts = {
	mappings = {
		add = "ms",
		delete = "md",
		-- "" means disabling binding
		find = "",
		find_left = "",
		highlight = "",
		replace = "",
		update_n_lines = "",
	},
	search_method = 'cover_or_prev',
	respect_selection_type = true,
}

M.keys = {
	{
		M.opts.mappings.add,
		[[:<C-u>lua MiniSurround.add('visual')<CR>]],
		mode = { 'v', 'x' },
		desc = 'Add surrounding to selection',
	},
}

M.config = function(_, opts)
	require('mini.surround').setup(opts)
	vim.g.minisurround_disable = false
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "NvimTree",
		callback = function()
			vim.b.minisurround_disable = true
	end,
	})
end

return M
