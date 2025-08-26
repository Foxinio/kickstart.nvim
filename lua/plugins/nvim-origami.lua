
local opts = {
	foldKeymaps = {
		setup = false,
	},
}

return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = opts,

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99

		require("origami").setup(opts)
	end,
}
