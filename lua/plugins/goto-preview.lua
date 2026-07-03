local M = { "rmagatti/goto-preview", }

M.dependencies = {
"rmagatti/session-lens",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"rmagatti/auto-session",
		'rmagatti/logger.nvim',
	}
}

M.opts = {
	width = 120; -- Width of the floating window
	height = 15; -- Height of the floating window
	default_mappings = false; -- Bind default mappings
	debug = false; -- Print debug information
	opacity = 0; -- 0-100 opacity level of the floating window where 100 is fully transparent.
	resizing_mappings = false; -- Binds arrow keys to resizing the floating window.
	post_open_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
	post_close_hook = nil; -- A function taking two arguments, a buffer and a window to be ran as a hook.
	references = { -- Configure the telescope UI for slowing the references cycling window.
		telescope = require("telescope.themes").get_dropdown({ hide_preview = false })
	};
	-- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
	focus_on_open = true; -- Focus the floating window when opening it.
	dismiss_on_move = false; -- Dismiss the floating window when moving the cursor.
	force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
	bufhidden = "unload", -- the bufhidden option to set on the floating window. See :h bufhidden
	stack_floating_preview_windows = true, -- Whether to nest floating windows
	preview_window_title = { enable = true, position = "left" }, -- Whether to set the preview window title as the filename
}

M.config = function()
	require('goto-preview').setup(M.opts)
		-- vim.keymap.set('n', '<leader>pd', goto.goto_preview_definition, { desc = '[P]review [D]efinition' })
		-- vim.keymap.set('n', '<leader>pr', goto.goto_preview_references, { desc = '[P]review [R]eferences' })
		-- vim.keymap.set('n', '<leader>pi', goto.goto_preview_implementation, { desc = '[P]review [I]mplementation' })
		-- vim.keymap.set('n', '<leader>pD', goto.goto_preview_declaration, { desc = '[P]review [D]eclaration' })
		-- vim.keymap.set('n', '<leader>pt', goto.goto_preview_type_definition, { desc = '[P]review [D]eclaration' })
		-- vim.keymap.set('n', '<leader>P', goto.close_all_win, { desc = 'Close all previews' })
end

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
	{ '<leader>pC', function()
			require('goto-preview').close_all_win() end,
		desc = 'Close all previews' },

}
return M
