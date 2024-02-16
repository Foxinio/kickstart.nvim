-- plugin for better commenting
return {
	'numToStr/Comment.nvim',
	opts = {
		toggler = {
			line = '<C-_>',
			block = '<C-_>'
		}
	},
	init = function()
		-- Comment bindings
		-- local comment_api = require("Comment.api")
		vim.keymap.set('n', "<C-/>", function()
			return vim.v.count == 0
					and '<Plug>(comment_toggle_linewise_current)'
					or '<Plug>(comment_toggle_linewise_count)'
		end, { expr = true, silent = true })

		vim.keymap.set('x', "<C-/>", '<Plug>(comment_toggle_linewise_visual)',
			{ silent = true })
	end
}
