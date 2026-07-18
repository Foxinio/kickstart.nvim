local M = {
	"chrisgrieser/nvim-origami",
}

M.event = "VeryLazy"

M.opts = {
	foldKeymaps = {
		setup = false,
	},
}

-- recommended: disable vim's auto-folding
M.init = function()
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
end

return M
