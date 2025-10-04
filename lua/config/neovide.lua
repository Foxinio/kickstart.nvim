-- font manipulation:
vim.keymap.set('n', '<C-}>', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
end, { desc = 'Increase font scale' })

vim.keymap.set('n', '<C-{>', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / 1.1
end, { desc = 'Decrease font scale' })

vim.g.neovide_scale_factor = 0.75
