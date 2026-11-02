local M = { 'Foxinio/verilator-dev.nvim' }

M.module = false

M.cmd = {
	'VerilatorDebugProfile', 'VerilatorDebugBinary', 'VerilatorDebug', 'VerilatorDebugBin',
	'VerilatorDebugTest', 'VerilatorDebugSim', 'VerilatorRegress', 'VerilatorHtml', 'VerilatorDiff',
}

M.dependencies = {
	'Foxinio/nvim-dap-extra.nvim',
	'mfussenegger/nvim-dap', 'stevearc/overseer.nvim', 'nvim-telescope/telescope.nvim',
	'nvim-lua/plenary.nvim', 'Foxinio/editable-telescope.nvim', 'Foxinio/term-color-parser.nvim',
}

M.init = function()
	vim.api.nvim_create_user_command('DebugProfile', function(args)
		vim.api.nvim_cmd({ cmd = 'VerilatorDebugProfile', args = args.fargs, bang = args.bang }, {})
	end, { nargs = '*', bang = true, force = true })
end

M.config = function()
	require('verilator-dev').setup({ wrap_debug_action = require('dap-extra.ui').action })
end

return M
