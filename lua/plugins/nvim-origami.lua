local M = {
	"chrisgrieser/nvim-origami",
}
M.opts = {
	autoFold = {
		enabled = false,
	},
	foldKeymaps = {
		setup = false,
	},
}

M.event = "VeryLazy"

M.config = function(_, opts)
	-- Keep files open on entry; folds are still available manually.
	vim.opt.foldenable = false
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99

	require("origami").setup(opts)
end

return M
