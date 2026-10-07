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
	terminal = {
		win = {
			keys = {
				term_hide = { "<C-q>", "hide", mode = { "n", "t" }, desc = "Hide terminal" },
			},
		},
	},
}

return M
