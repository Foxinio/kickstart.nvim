return {
	"Exafunction/windsurf.nvim",
	enabled = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	opts = {
		enable_chat = true,
		virtual_text = {
			manual = true,
			map_keys = false,
			key_bindings = {
				accept = "<C-g>",
				next = "<C-.>",
				prev = "<C-,>",
				clear = "<C-x>",
			},
		},
	},
	config = function()
		require("codeium").setup()
	end,
}


