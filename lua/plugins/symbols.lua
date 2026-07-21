local M = {
	"oskarrrrrrr/symbols.nvim",
}

M.enabled = false

M.opts = {
	sidebar = {
		preview = {
			show_always = true,
			show_line_number = true,
		},
		keymaps = {
			["<BS>"] = "fold",
			["<Tab>"] = "unfold",
		},
	},
}

M.keys = {
	{ ",s", "<cmd>Symbols<CR>" },
	{ ",S", "<cmd>SymbolsClose<CR>" },
}

M.config = function(_, opts)
	local r = require("symbols.recipes")
	require("symbols").setup(
		r.DefaultFilters,
		r.AsciiSymbols,
		opts
	)

	vim.api.nvim_create_autocmd({"FileType", "BufWinEnter", }, {
		pattern = { "SymbolsSidebar", "symbols" },
		callback = function()
			vim.defer_fn(function()
				vim.opt_local.spell = false
			end, 50)
		end,
	})
end

return M
