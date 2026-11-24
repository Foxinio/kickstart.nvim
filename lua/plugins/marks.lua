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
	sign_priority = 1,
}

return M
