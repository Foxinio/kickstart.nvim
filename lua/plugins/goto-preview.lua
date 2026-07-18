local M = {
	"rmagatti/goto-preview",
}

M.dependencies = {
	{
		"rmagatti/session-lens",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"rmagatti/auto-session",
			'rmagatti/logger.nvim',
		},
	},
}

M.opts = {
	opacity = 0; -- 0-100 opacity level of the floating window where 100 is fully transparent.
	bufhidden = "unload", -- the bufhidden option to set on the floating window. See :h bufhidden
}

M.keys = {
	{ '<leader>pd', function()
			require('goto-preview').goto_preview_definition() end,
		desc = '[P]review [D]efinition' },
	{ '<leader>pr', function()
			require('goto-preview').goto_preview_references() end,
		desc = '[P]review [R]eferences' },
	{ '<leader>pi', function()
			require('goto-preview').goto_preview_implementation() end,
		desc = '[P]review [I]mplementation' },
	{ '<leader>pD', function()
			require('goto-preview').goto_preview_declaration() end,
		desc = '[P]review [D]eclaration' },
	{ '<leader>pt', function()
			require('goto-preview').goto_preview_type_definition() end,
		desc = '[P]review [D]eclaration' },
	{ '<leader>pQ', function()
			require('goto-preview').close_all_win() end,
		desc = 'Close all previews' },

}
return M
