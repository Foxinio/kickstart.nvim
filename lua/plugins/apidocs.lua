local M = {
  'Foxinio/apidocs.nvim',
}

M.branch = 'dev'

M.dependencies = {
  'nvim-treesitter/nvim-treesitter',
}

M.cmd = { 'ApidocsSearch', 'ApidocsInstall', 'ApidocsOpen', 'ApidocsSelect', 'ApidocsUninstall' }

M.opts = { picker = 'telescope' }

M.keys = {
	{
		'<leader>sks',
		function()
			local apidocs = require('apidocs')
			if vim.bo[0] and vim.bo[0].filetype ~= nil then
				return apidocs.apidocs_search({restrict_sources={vim.bo[0].filetype}})
			end
			return apidocs.apidocs_search({})
		end,
		desc = 'Search Api Doc',
	},
	{
		'<leader>skd',
		function()
			local apidocs = require('apidocs')
			if vim.bo[0] and vim.bo[0].filetype ~= nil then
				return apidocs.apidocs_open({restrict_sources={vim.bo[0].filetype}})
			end
			return apidocs.apidocs_open({})
		end,
		desc = 'Open Api Doc',
	},
	{ '<leader>skS', function() require('apidocs').apidocs_search() end, desc = 'Search Api Doc (all)' },
	{ '<leader>skD', function() require('apidocs').apidocs_open() end, desc = 'Open Api Doc (all)' },
}

return M
