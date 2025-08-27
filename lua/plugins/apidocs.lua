return {
  'Foxinio/apidocs.nvim',
	branch = 'dev',
	-- dir = '/home/foxinio/Work/nvim-plugins/apidocs.nvim',
  dependencies = {
    'folke/snacks.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  -- cmd = { 'ApidocsSearch', 'ApidocsInstall', 'ApidocsOpen', 'ApidocsSelect', 'ApidocsUninstall' },
	opts = { picker = 'telescope' },
  config = function(opts)
		local apidocs = require('apidocs')
    apidocs.setup({ picker = 'telescope' })

		require('which-key').add({
			{ '<leader>sas', function()
				if vim.bo[0] and vim.bo[0].filetype ~= nil then
					return apidocs.apidocs_search({restrict_sources={vim.bo[0].filetype}})
				end
				return apidocs.apidocs_search({})
			end, desc = 'Search Api Doc' },
			{ '<leader>sad', function()
				if vim.bo[0] and vim.bo[0].filetype ~= nil then
					return apidocs.apidocs_open({restrict_sources={vim.bo[0].filetype}})
				end
				return apidocs.apidocs_open({})
			end, desc = 'Open Api Doc' },
			{ '<leader>saS', apidocs.apidocs_search, desc = 'Search Api Doc (all)' },
			{ '<leader>saD', apidocs.apidocs_open, desc = 'Open Api Doc (all)' },
		})
  end,
}
