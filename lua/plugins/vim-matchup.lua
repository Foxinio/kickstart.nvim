local M = {
  'andymass/vim-matchup',
}

-- or use the `opts` mechanism built into `lazy.nvim`. It calls
-- `require('match-up').setup` under the hood
---@type matchup.Config
M.opts = {
	treesitter = {
		stopline = 500,
	}
}

return M
