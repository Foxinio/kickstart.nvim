-- Useful plugin to show you pending keybinds.
local M = {
	'folke/which-key.nvim',
}

M.opts = {
	preset = "classic",
}

M.keys = {
	{ "<leader>wk", "<cmd>WhichKey<CR>", mode = { "n", "x", "s", "v", "t", "c" }, silent = true },
}

M.config = function(_, opts)
	require("which-key").setup(opts)

	local presets = require("which-key.plugins.presets")
	presets.operators["v"] = nil

	require("which-key").add({
		{ "x", group = "Diagnostics" },
		{ "<leader>c",  group = "[C]ode" },
		{ "<leader>c_", hidden = true },
		{ "<leader>d",  group = "[D]ocument" },
		{ "<leader>d_", hidden = true },
		{ "<leader>g",  group = "[G]o to" },
		{ "<leader>g_", hidden = true },
		{ "<leader>h",  group = "Git [H]unk" },
		{ "<leader>h_", hidden = true },
		{ "<leader>r",  group = "[R]ename" },
		{ "<leader>r_", hidden = true },
		{ "<leader>s",  group = "[S]earch" },
		{ "<leader>s_", hidden = true },
		{ "<leader>t",  group = "[T]oggle" },
		{ "<leader>t_", hidden = true },
		{ "<leader>w",  group = "[W]orkspace" },
		{ "<leader>w_", hidden = true },
		{ "<leader>",  group = "VISUAL <leader>", mode = "v" },
		{ "<leader>h", desc = "Git [H]unk",       mode = "v" },
	})
end

return M
