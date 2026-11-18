-- Debugger UI (Foxinio fork): panes, the dedicated debug tab, source routing,
-- :DapRestoreLayout and :DapClean. Loaded with nvim-dap (see debug.lua).
local M = { 'Foxinio/nvim-dap-ui' }

M.module = false

M.cmd = { 'DapClean', 'DapRestoreLayout' }

M.dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' }

M.opts = {
	source_window = { winbar = 'DAP Source' },
	element_mappings = {
		stacks = { expand = '<2-LeftMouse>', open = { '<CR>', 'o' }, toggle = { '<Space>', 't' } },
		breakpoints = { expand = '<2-LeftMouse>', open = { '<CR>', 'o' }, toggle = 't', remove = 'd' },
	},
	icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
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
				{ id = 'repl', size = 0.5 },
				{ id = 'console', size = 0.5 },
			},
			position = 'bottom',
			size = 12,
		},
	},
	floating = { border = 'rounded' },
	controls = {
		enabled = true,
		element = 'repl',
		icons = {
			pause = '⏸',
			play = '▶',
			step_into = '⏎',
			step_over = '⏭',
			step_out = '⏮',
			step_back = 'b',
			run_last = '▶▶',
			terminate = '⏹',
			disconnect = '⏏',
		},
	},
}

M.config = function(_, opts) require('dapui').setup(opts) end

return M
