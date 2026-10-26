local M = { 'Foxinio/nvim-dap-extra.nvim' }
M.dir = vim.fn.stdpath('config') .. '/external/nvim-dap-extra.nvim'
M.module = false
M.cmd = { 'DapClean' }
M.dependencies = {
	'mfussenegger/nvim-dap', 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio',
	'theHamsta/nvim-dap-virtual-text',
}
M.config = function(_, opts) require('dap-extra').setup(opts) end
return M
