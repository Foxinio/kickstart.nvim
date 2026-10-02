local M = {
	"nickjvandyke/opencode.nvim",
}

M.lazy = true
M.module = false

M.keys = {
	{
		"<leader>ioa",
		function() require("opencode").ask("@this: ") end,
		mode = { "n", "x" },
		desc = "Ask OpenCode",
	},
	{
		"<leader>ios",
		function() require("opencode").select() end,
		mode = { "n", "x" },
		desc = "Select OpenCode action",
	},
	{
		"<leader>iob",
		function() require("opencode").ask("@buffer: ") end,
		desc = "Ask OpenCode about current buffer",
	},
}

return M
