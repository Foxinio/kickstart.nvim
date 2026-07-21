local M = {
	"oskarrrrrrr/symbols.nvim",
	enabled = false,
}
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

M.config = function()
	local r = require("symbols.recipes")
	require("symbols").setup(
		r.DefaultFilters,
		r.AsciiSymbols,
		M.opts
	)
	vim.keymap.set("n", ",s", "<cmd>Symbols<CR>")
	vim.keymap.set("n", ",S", "<cmd>SymbolsClose<CR>")

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
