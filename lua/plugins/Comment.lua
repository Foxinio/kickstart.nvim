-- plugin for better commenting
local M = {
	'numToStr/Comment.nvim',
}

M.opts = {
	toggler = {
		line = '<C-_>',
		block = '<C-_>',
	},
}

M.keys = {
	{
		'<C-/>',
		function()
			return vim.v.count == 0
					and '<Plug>(comment_toggle_linewise_current)'
					or '<Plug>(comment_toggle_linewise_count)'
		end,
		expr = true,
		silent = true,
	},
	{ '<C-/>', '<Plug>(comment_toggle_linewise_visual)', mode = 'x', silent = true },
}

return M
