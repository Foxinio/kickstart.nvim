-- Git diff hunks.
-- https://github.com/echasnovski/mini.diff

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.diff.lua

local icons = require("utils.icons")
local opts = {
	view = {
		style = "sign",
		signs = {
			add = icons.git.Add.text,
			change = icons.git.Change.text,
			delete = icons.git.Delete.text,
		},
	},
	mappings = {
		apply = "gh",
		reset = "gH",
		textobject = "gh",
		goto_first = "[C",
		goto_prev = "[c",
		goto_next = "]c",
		goto_last = "]C",
	},
}

return {
	"echasnovski/mini.diff",
-- TODO : Configure this
	enabled = false,
	config = function()
		local diff = require("mini.diff")

		diff.setup(opts)
		require('which-key').add({
			{ "<leader>hd", diff.toggle_overlay, desc = "Toggle diff overlay" },
		})
	end,
	opts = opts,
	event = "BufRead",
}
