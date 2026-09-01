local M = {
	"ThePrimeagen/refactoring.nvim",
}

M.module = false

M.dependencies = {
	"lewis6991/async.nvim",
}

M.keys = {
	{
		"<leader>cr",
		function()
			require("refactoring").select_refactor()
		end,
		mode = { "n", "x" },
		desc = "[R]efactor",
	},
}

M.opts = {}

return M
