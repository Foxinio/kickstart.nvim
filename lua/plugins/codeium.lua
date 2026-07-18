local M = {
	'Exafunction/codeium.vim',
}

M.enabled = false

M.keys = {
	{ '<C-h>', function() return vim.fn['codeium#Complete']() end, mode = 'i', expr = true, silent = true },
	{ '<C-g>', function() return vim.fn['codeium#Accept']() end, mode = 'i', expr = true, silent = true },
	{ '<c-.>', function() return vim.fn['codeium#CycleCompletions'](1) end, mode = 'i', expr = true, silent = true },
	{ '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, mode = 'i', expr = true, silent = true },
	{ '<c-x>', function() return vim.fn['codeium#Clear']() end, mode = 'i', expr = true, silent = true },
}

M.init = function()
	vim.g.codeium_disable_bindings = 1
	vim.g.codeium_manual = 1
end

M.config = function()
	vim.api.nvim_create_augroup('CodiumAuGroup', {})
	vim.api.nvim_create_autocmd('CursorHoldI', {
		group = 'CodiumAuGroup',
		desc = 'Codium sugest code when no cursor movement detected',
		callback = function()
			return vim.fn['codeium#Complete']()
		end,
	})
end

return M
