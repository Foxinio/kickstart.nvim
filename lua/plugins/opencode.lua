local M = {
	"nickjvandyke/opencode.nvim",
}

M.lazy = true
M.module = false

local terminal_opts = {
	win = { position = "float", width = 0.8, height = 0.8, border = "rounded" },
}

M.config = function()
	require("opencode.config").opts.server.start = function()
		require("snacks.terminal").open("opencode", terminal_opts)
	end
end

M.keys = {
	{
		"<leader>ioc",
		function() require("snacks.terminal").toggle("opencode", terminal_opts) end,
		desc = "Toggle OpenCode chat",
	},
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
