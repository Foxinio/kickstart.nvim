local M = {
	"folke/snacks.nvim",
}

M.lazy = false
M.priority = 1000

-- Only opt-in modules; everything else stays disabled.
M.opts = {
	bigfile = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
}

return M
