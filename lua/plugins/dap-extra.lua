local M = { 'Foxinio/nvim-dap-extra.nvim' }

M.module = false

M.cmd = { 'DapClean' }

M.dependencies = {
	-- Fork with source-window routing; dap-extra relies on it.
	'Foxinio/nvim-dap-ui', 'nvim-neotest/nvim-nio',
	'theHamsta/nvim-dap-virtual-text',
}

M.opts = {
	dapui = { source_window = { winbar = 'DAP Source' } },
}

M.config = function(_, opts) require('dap-extra').setup(opts) end

return M
