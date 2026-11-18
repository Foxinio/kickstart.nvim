local M = {
	'Foxinio/verilator-dev.nvim',
	url = 'git@github.com:Foxinio/verilator-dev.nvim.git',
}

M.module = false

M.keys = {
	{ '<leader>dv', function() require('verilator-dev.debug').regression('', false) end, desc = 'Debug Verilator test' },
}

M.cmd = {
	'VerilatorDebugProfile', 'VerilatorDebugBinary', 'VerilatorDebug', 'VerilatorDebugBin',
	'VerilatorDebugTest', 'VerilatorDebugSim', 'VerilatorRegress', 'VerilatorHtml', 'VerilatorDiff',
}

M.dependencies = {
	'mfussenegger/nvim-dap',
	'Foxinio/nvim-dap-ui',
	'Foxinio/nvim-dap-extra.nvim',
	'stevearc/overseer.nvim', 'nvim-telescope/telescope.nvim',
	'nvim-lua/plenary.nvim', 'Foxinio/editable-telescope.nvim', 'Foxinio/term-color-parser.nvim',
}

M.init = function()
	vim.api.nvim_create_user_command('DebugProfile', function(args)
		vim.api.nvim_cmd({ cmd = 'VerilatorDebugProfile', args = args.fargs, bang = args.bang }, {})
	end, { nargs = '*', bang = true, force = true })
end

-- lazy.nvim passes these to require('verilator-dev').setup().
M.opts = {
	wrap_debug_action = function(callback, use_cursor)
		return require('dapui').debug_tab.action(callback, { use_cursor = use_cursor })
	end,
}

return M
