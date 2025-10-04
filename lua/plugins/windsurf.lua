return {
	"Exafunction/windsurf.nvim",
	lazy = true,
	cmd = "WindsurfLoad",
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
		require("codeium").disable()

    vim.api.nvim_create_user_command("CodeiumEnable", function()
      require("codeium").enable()
    end, {})
	end,
}


