-- Git diff hunks.
-- https://github.com/echasnovski/mini.diff

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.diff.lua

-- TODO : Configure this
local M = {
	"echasnovski/mini.diff",
}

M.enabled = false
M.event = "BufRead"

local icons = require("utils.icons")
M.opts = {
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

M.keys = {
	{ "<leader>hd", function() require('mini.diff').toggle_overlay() end, desc = "Toggle diff overlay" },

}

return M
