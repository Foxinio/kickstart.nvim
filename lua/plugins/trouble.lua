local M =  { "folke/trouble.nvim" }


M.cmd = { "Trouble", "Trouble" }
M.opts = {
	use_diagnostic_signs = true,
	modes = {
		mysymbols = {
			desc = "LSP Symbols",
			mode = "lsp_document_symbols",
			focus = true,
			win = { position = "right", width = 30 },
      preview = {
        type = "float",
        relative = "editor",
        border = "rounded",
        anchor = "NE",
        title = "Preview",
        title_pos = "center",
        position = { 0, -2 },
        size = { width = 0.3, height = 0.1 },
        -- zindex = 200,
      },
			keys = {
				["<TAB>"] = "fold_open",
				["<BS>"]  = "fold_close",
				["<CR>"]  = "jump",
			},
		},
	},
}
M.keys = {
	-- { ",s",
	-- 	"<cmd>Trouble mysymbols open focus=true<cr>",
	-- 	desc = "Symbols (Trouble)",
	-- },
	-- { ",s",
	-- 	"<cmd>Trouble mysymbols close<cr>",
	-- 	desc = "Symbols (Trouble)",
	-- },
	{
		"<leader>cs",
		"<cmd>Trouble symbols toggle focus=false<cr>",
		desc = "Symbols (Trouble)",
	},
	{
		"<leader>xx",
		"<cmd>Trouble diagnostics toggle<cr>",
		desc = "Diagnostics (Trouble)",
	},
	{
		"<leader>xX",
		"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
		desc = "Buffer Diagnostics (Trouble)",
	},
	{
		"<leader>cs",
		"<cmd>Trouble symbols toggle focus=false<cr>",
		desc = "Symbols (Trouble)",
	},
	{
		"<leader>cl",
		"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
		desc = "LSP Definitions / references / ... (Trouble)",
	},
	{
		"<leader>xL",
		"<cmd>Trouble loclist toggle<cr>",
		desc = "Location List (Trouble)",
	},
	{
		"<leader>xQ",
		"<cmd>Trouble qflist toggle<cr>",
		desc = "Quickfix List (Trouble)",
	},
	{
		"[q",
		function()
			if require("trouble").is_open() then
				require("trouble").previous({ skip_groups = true, jump = true })
			else
				local ok, err = pcall(vim.cmd.cprev)
				if not ok then
					vim.notify(err, vim.log.levels.ERROR)
				end
			end
		end,
		desc = "Previous trouble/quickfix item",
	},
	{
		"]q",
		function()
			if require("trouble").is_open() then
				require("trouble").next({ skip_groups = true, jump = true })
			else
				local ok, err = pcall(vim.cmd.cnext)
				if not ok then
					vim.notify(err, vim.log.levels.ERROR)
				end
			end
		end,
		desc = "Next trouble/quickfix item",
	},
}

return M
