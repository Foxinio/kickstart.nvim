local M = {
	"Exafunction/windsurf.nvim",
}

M.module = false
M.cmd = { "StartCodeium" }

M.dependencies = {
	"nvim-lua/plenary.nvim",
	-- "hrsh7th/nvim-cmp",
}

M.opts = {
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
}

M.config = function(_, opts)
	require("codeium").setup(opts)
	require("blink.cmp").add_source_provider("codeium", {
		name = "Codeium",
		module = "codeium.blink",
		async = true,
	})

	vim.api.nvim_create_user_command("StartCodeium", function()
		require("codeium").enable()
	end, {})
end

return M
