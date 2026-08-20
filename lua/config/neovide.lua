-- font manipulation:
vim.keymap.set('n', '<C-}>', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
end, { desc = 'Increase font scale' })

vim.keymap.set('n', '<C-{>', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / 1.1
end, { desc = 'Decrease font scale' })

vim.g.neovide_scale_factor = 0.75

vim.defer_fn(function() vim.cmd.NeovideFocus() end, 500)

vim.api.nvim_create_autocmd('VimResized', {
	callback = function()
		vim.cmd('wincmd =')
		vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 0 })
	end,
	desc = 'Reset window sizes and cursor column after Neovide resize',
})
