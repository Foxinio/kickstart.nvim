-- Surround actions.
-- https://github.com/echasnovski/mini.surround

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.surround.lua

return {
	"echasnovski/mini.surround",
-- TODO : Configure this
	opts = {
		mappings = {
			add = "ys",
			delete = "ds",
			find = "",
			find_left = "",
			highlight = "",
			replace = "",
			update_n_lines = "",
		},
	},
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "NvimTree",
			callback = function()
				vim.b.minisurround_disable = false
			end,
		})
	end
}
