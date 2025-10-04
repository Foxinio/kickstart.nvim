-- Surround actions.
-- https://github.com/echasnovski/mini.surround

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.surround.lua

local M = {
	"echasnovski/mini.surround",
}

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

M.config = function()
	require('mini.surround').setup(M.opts)
	vim.g.minisurround_disable = false
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "NvimTree",
		callback = function()
			vim.b.minisurround_disable = true
		end,
	})
	-- TODO : throw out mappings as they are supposed to be done (via opts.mappings)
	-- and do them using `require('which-key').add({ ... })
	vim.keymap.set({'v', 'x'}, M.opts.mappings.add,
			[[:<C-u>lua MiniSurround.add('visual')<CR>]],
			{ desc = 'Add surrounding to selection' })
end

return M
