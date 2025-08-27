	return {
	"lervag/vimtex",
	lazy = false,     -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	filetype = "latex",
	keys = {
		{ "<leader>li", "<plug>(vimtex-info)",
			mode = "n", desc = "Vimtex info" },
		{ "<leader>lI", "<plug>(vimtex-info-full)",
			mode = "n", desc = "Vimtex full info" },
		{ "<leader>lt", "<plug>(vimtex-toc-open)",
			mode = "n", desc = "Vimtex open TOC" },
		{ "<leader>lT", "<plug>(vimtex-toc-toggle)",
			mode = "n", desc = "Vimtex TOC toggle" },
		{ "<leader>lq", "<plug>(vimtex-log)",
			mode = "n", desc = "Vimtex open log" },
		{ "<leader>lv", "<plug>(vimtex-view)",
			mode = "n", desc = "Vimtex view" },
		{ "<leader>lr", "<plug>(vimtex-reverse-search)",
			mode = "n", desc = "Vimtex reverse search" },
		{ "<leader>ll", "<plug>(vimtex-compile)",
			mode = "n", desc = "Vimtex compile" },
		{ "<leader>lL", "<plug>(vimtex-compile-selected)",
			mode = { "n", "x" }, desc = "Vimtex compile selected" },
		{ "<leader>lk", "<plug>(vimtex-stop)",
			mode = "n", desc = "Vimtex stop compilation" },
		{ "<leader>lK", "<plug>(vimtex-stop-all)",
			mode = "n", desc = "Vimtex stop all compliation" },
		{ "<leader>le", "<plug>(vimtex-errors)",
			mode = "n", desc = "Vimtex show errors" },
		{ "<leader>lo", "<plug>(vimtex-compile-output)",
			mode = "n", desc = "Vimtex show compilation output" },
		{ "<leader>lg", "<plug>(vimtex-status)",
			mode = "n", desc = "Vimtex status" },
		{ "<leader>lG", "<plug>(vimtex-status-all)",
			mode = "n", desc = "Vimtex status all" },
		{ "<leader>lc", "<plug>(vimtex-clean)",
			mode = "n", desc = "Vimtex clean" },
		{ "<leader>lC", "<plug>(vimtex-clean-full)",
			mode = "n", desc = "Vimtex full clean" },
		{ "<leader>lm", "<plug>(vimtex-imaps-list)",
			mode = "n" },
		{ "<leader>lx", "<plug>(vimtex-reload)",
			mode = "n", desc = "Vimtex reload" },
		{ "<leader>lX", "<plug>(vimtex-reload-state)",
			mode = "n" },
		{ "<leader>ls", "<plug>(vimtex-toggle-main)",
			mode = "n", desc = "Vimtex toggle main" },
		{ "<leader>la", "<plug>(vimtex-context-menu)",
			mode = "n", desc = "Vimtex context menu" },
	},
	init = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_general_viewer = 'okular'
		vim.g.vimtex_view_general_options = '--unique file:@pdf\\#src:@line@tex'
		vim.g.vimtex_quickfix_mode = 0
		vim.g.vimtex_quickfix_open_on_warning = 0
		vim.g.vimtex_quickfix_ignore_filters = {
			'Package .* Warning:',
			'LaTeX Warning: Empty .* environment',
			'I found no \\citation commands',
		}
		vim.g.vimtex_quickfix_autoclose_after_keystrokes = 0
	end
}
