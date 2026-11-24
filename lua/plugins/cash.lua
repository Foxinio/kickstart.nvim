local M = { "nullromo/cash.nvim" }

M.main = "cash"
M.event = "VeryLazy"
M.cmd = { "Cash" }
M.opts = {
	mapKeys = {
		questionMark = false,
		functionKeys = false,
	},
}

return M
