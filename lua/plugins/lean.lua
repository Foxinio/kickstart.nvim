local M ={
  'Julian/lean.nvim',
	tag = 'nvim-0.11',
}
M.event = { 'BufReadPre *.lean', 'BufNewFile *.lean' }
M.module = false

M.dependencies = {
	-- optional dependencies:

	'nvim-telescope/telescope.nvim', -- for Lean-specific pickers
	'andymass/vim-matchup',          -- for enhanced % motion behavior
	-- 'andrewradev/switch.vim',        -- for switch support
	-- 'tomtom/tcomment_vim',           -- for commenting
}

  ---@type lean.Config
M.opts = { -- see the manual for full configuration options
	mappings = true,
	infoview = {
		width = 40,
		orientation = 'vertical',
	},
}

M.config = function(_, opts)
	vim.lsp.config('leanls', {
		on_attach = require('plugin-utils.lspconfig').on_attach,
	})
	require('lean').setup(opts)
end

return M
