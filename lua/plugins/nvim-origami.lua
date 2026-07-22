local M = {
	"chrisgrieser/nvim-origami",
}

M.event = "VeryLazy"

M.opts = {
	foldKeymaps = {
		setup = false,
	},
}

M.event = "VeryLazy"

M.init = function()
	-- Keep files open on entry; folds are still available manually.
	vim.opt.foldenable = false
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
end

return M
