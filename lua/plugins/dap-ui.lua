-- Debugger UI (Foxinio fork): panes, the dedicated debug tab, source routing,
-- :DapRestoreLayout and :DapClean. Loaded with nvim-dap (see debug.lua).
local M = { 'Foxinio/nvim-dap-ui' }

M.module = false

M.cmd = { 'DapClean', 'DapRestoreLayout' }

M.dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' }

M.opts = {
	source_window = { winbar = 'DAP Source' },
	element_mappings = {
		watches = {
			expand = { '<Tab>' },
			edit = { '<C-e>' },
			remove = { '<C-d>' },
		},
		scopes = {
			expand = { '<Tab>' },
			edit = { '<C-e>' },
			remove = { '<C-d>' },
		},
		stacks = {
			expand = { '<2-LeftMouse>', 'o', },
			open = { '<CR>', },
			toggle = { '<Tab>', }
		},
		breakpoints = {
			expand = { '<2-LeftMouse>', '<Tab>' },
			open = { '<CR>', 'o' },
			toggle = { '<C-t>' },
			edit = { '<C-e>' },
		},
	},
	layouts = {
		{
			elements = {
				{ id = 'scopes', size = 0.45 },
				{ id = 'breakpoints', size = 0.15 },
				{ id = 'stacks', size = 0.25 },
				{ id = 'watches', size = 0.15 },
			},
			position = 'left',
			size = 48,
		},
		{
			elements = {
				{ id = 'repl', size = 0.75 },
				{ id = 'console', size = 0.25 },
			},
			position = 'bottom',
			size = 12,
		},
	},
}

return M
