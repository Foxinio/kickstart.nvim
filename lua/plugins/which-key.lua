-- Useful plugin to show you pending keybinds.
local M = {
	'folke/which-key.nvim',
}

M.opts = {
	preset = "classic",
	triggers = {
		{ "<auto>", mode = "nixsotc" },
		{ "m",      mode = "n" },
		{ "dm",     mode = "n" },
	},
}

M.keys = {
	{ "<leader>wk", "<cmd>WhichKey<CR>", mode = { "n", "x", "s", "v", "t", "c" }, silent = true },
}

M.config = function(_, opts)
	require("which-key").setup(opts)

	local presets = require("which-key.plugins.presets")
	presets.operators["v"] = nil

	require("which-key").add({
		{ "m",         group = "Marks" },
		{ "m,",        desc = "Set next lowercase mark" },
		{ "m;",        desc = "Toggle next mark on current line" },
		{ "m[",        desc = "Previous mark" },
		{ "m]",        desc = "Next mark" },
		{ "m:",        desc = "Preview mark" },
		{ "m{",        desc = "Previous bookmark of current type" },
		{ "m}",        desc = "Next bookmark of current type" },
		{ "m0",        desc = "Set bookmark group 0" },
		{ "m1",        desc = "Set bookmark group 1" },
		{ "m2",        desc = "Set bookmark group 2" },
		{ "m3",        desc = "Set bookmark group 3" },
		{ "m4",        desc = "Set bookmark group 4" },
		{ "m5",        desc = "Set bookmark group 5" },
		{ "m6",        desc = "Set bookmark group 6" },
		{ "m7",        desc = "Set bookmark group 7" },
		{ "m8",        desc = "Set bookmark group 8" },
		{ "m9",        desc = "Set bookmark group 9" },
		{ "m.",        desc = "Builtin .: last change position" },
		{ "m^",        desc = "Builtin ^: last insert position" },
		{ "m<",        desc = "Builtin <: visual selection start" },
		{ "m>",        desc = "Builtin >: visual selection end" },
		{ "dm",        group = "Delete marks" },
		{ "dmx",       desc = "Delete mark x" },
		{ "dm-",       desc = "Delete marks on current line" },
		{ "dm<Space>", desc = "Delete marks in current buffer" },
		{ "dm=",       desc = "Delete bookmark under cursor" },
		{ "dm0",       desc = "Delete bookmark group 0" },
		{ "dm1",       desc = "Delete bookmark group 1" },
		{ "dm2",       desc = "Delete bookmark group 2" },
		{ "dm3",       desc = "Delete bookmark group 3" },
		{ "dm4",       desc = "Delete bookmark group 4" },
		{ "dm5",       desc = "Delete bookmark group 5" },
		{ "dm6",       desc = "Delete bookmark group 6" },
		{ "dm7",       desc = "Delete bookmark group 7" },
		{ "dm8",       desc = "Delete bookmark group 8" },
		{ "dm9",       desc = "Delete bookmark group 9" },
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
