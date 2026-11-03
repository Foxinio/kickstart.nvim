local M = {}

function M.guard_scroll_events()
	-- Noice emits synthetic WinScrolled events without a window ID.
	for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ group = 'Symbols', event = 'WinScrolled' })) do
		if autocmd.pattern == '*' and autocmd.callback then
			vim.api.nvim_del_autocmd(autocmd.id)
			vim.api.nvim_create_autocmd('WinScrolled', {
				group = 'Symbols',
				callback = function(event)
					if tonumber(event.match) then return autocmd.callback(event) end
				end,
			})
		end
	end
end

return M
