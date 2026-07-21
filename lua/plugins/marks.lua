local M = {
	"chentoast/marks.nvim",
}
M.event = "VeryLazy"
M.opts = {
	default_mappings = true,
	builtin_marks = { ".", "<", ">", "^" },
	cyclic = true,
	force_write_shada = false,
	refresh_interval = 250,
	sign_priority = {
		lower = 10,
		upper = 15,
		builtin = 8,
		bookmark = 20,
	},
}

return M
