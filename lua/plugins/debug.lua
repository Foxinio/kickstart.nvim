local M = { 'mfussenegger/nvim-dap' }

local debug = require('plugin-utils.debug')

M.module = false

M.dependencies = {
	'Foxinio/nvim-dap-ui',
	'Foxinio/nvim-dap-extra.nvim',
	'nvim-telescope/telescope-dap.nvim',
	'nvim-telescope/telescope.nvim',
	'Foxinio/editable-telescope.nvim',

	'williamboman/mason.nvim',
	'jay-babu/mason-nvim-dap.nvim',

	'civitasv/cmake-tools.nvim',
}

M.keys = {
	{ '<F5>', debug.action(debug.continue_or_cmake_debug), desc = 'Debug: Start/Continue' },
	{ '<F10>', debug.action(function() require('dap').step_over() end), desc = 'Debug: Step Over' },
	{ '<F11>', debug.action(function() require('dap').step_into() end), desc = 'Debug: Step Into' },
	{ '<F12>', debug.action(function() require('dap').step_out() end), desc = 'Debug: Step Out' },
	{ '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
	{ '<leader>dc', debug.action(debug.continue_or_cmake_debug), desc = 'Debug: Start/Continue' },
	{ '<leader>dC', debug.action(debug.cmake_quick_debug), desc = 'Debug: CMake Target' },
	{ '<leader>df', debug.action(debug.cmake_debug_current_file, true), desc = 'Debug: CMake Current File' },
	{ '<leader>dq', debug.action(function() require('dap').terminate() end), desc = 'Debug: Terminate' },
	{ '<leader>dR', debug.action(function() require('dap').restart() end), desc = 'Debug: Restart' },
	{ '<leader>dr', function() require('dapui').debug_tab.repl() end, desc = 'Debug: Toggle REPL' },
	-- Duplicated by <leader>sb; this binding can be removed if needed.
	{ '<leader>dB', debug.action(function() require('dap').list_breakpoints() end), desc = 'Debug: List Breakpoints' },
	-- Duplicated by <leader>dB; this binding can be removed if needed.
	{ '<leader>sb', debug.action(function() require('dap').list_breakpoints() end), desc = 'Debug: List Breakpoints' },
	{ '<leader>ds', debug.action(function() require('telescope').extensions.dap.configurations() end), desc = 'Debug: Select Configuration' },
	{ '<leader>dS', debug.action(function() require('telescope').extensions.dap.frames() end), desc = 'Debug: Select Stack Frame' },
	{ '<leader>dl', debug.action(function() require('dap').run_to_cursor() end, true), desc = 'Debug: Run To Cursor' },
	{ '<leader>dk', debug.action(function() require('dap').up() end), desc = 'Debug: Go up current stacktrace' },
	{ '<leader>dj', debug.action(function() require('dap').down() end), desc = 'Debug: Go down current stacktrace' },
	{ '<leader>dK', function() require('dap.ui.widgets').hover() end, desc = 'Debug: Inspect value under cursor' },
	{ '<leader>dg', function() require('dap-extra').local_frame() end, desc = 'Debug: Show current frame here' },
	{ '<leader>dbc', function()
		require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
	end, desc = 'Debug: Conditional Breakpoint' },
	{ '<leader>dbn', function()
		require('dap').set_breakpoint(nil, vim.fn.input 'Breakpoint hit condition: ')
	end, desc = 'Debug: Hit-count Breakpoint' },
	{ '<leader>dbl', function()
		require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
	end, desc = 'Debug: Logpoint' },
	{ '<F7>', function() require('dapui').toggle() end, desc = 'Debug: See last session result.' },
}
M.opts = {
	handlers = {},
	ensure_installed = { 'codelldb', 'cppdbg', 'delve', 'earlybird' },
}

M.config = function(_, opts) debug.setup(opts) end

return M
