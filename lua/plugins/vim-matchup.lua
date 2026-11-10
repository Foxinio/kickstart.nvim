local M = {
  'andymass/vim-matchup',
}

-- or use the `opts` mechanism built into `lazy.nvim`. It calls
-- `require('match-up').setup` under the hood
---@type matchup.Config
M.opts = {
	matchparen = {
		deferred = 1,
		deferred_show_delay = 200,
		stopline = 100,
		timeout = 30,
		insert_timeout = 15,
	},
	treesitter = {
		stopline = 100,
	}
}

return M
