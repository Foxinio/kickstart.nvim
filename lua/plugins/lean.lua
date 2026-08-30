local M ={
  'Julian/lean.nvim',
	tag = 'nvim-0.11',
}
M.event = { 'BufReadPre *.lean', 'BufNewFile *.lean' }

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
}

return M
