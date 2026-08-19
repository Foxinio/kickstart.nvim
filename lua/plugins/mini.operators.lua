-- Text edit operators
-- https://github.com/echasnovski/mini.operators

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.operators.lua

local M = {
	"echasnovski/mini.operators",
}

M.enabled = false

-- TODO : Configure this
M.opts = {
	exchange = {
		prefix = "<leader>x",
	},
	multiply = {
		prefix = "<leader>m",
	},
	replace = {
		prefix = "<leader>r",
	},
	sort = {
		prefix = "<leader>sl",
	},
}

return M
