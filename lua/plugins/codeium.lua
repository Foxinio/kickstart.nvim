vim.g.codeium_disable_bindings = 1
vim.g.codeium_manual = 1

-- Change '<C-g>' here to any keycode you like.
vim.keymap.set('i', '<C-h>', function () return vim.fn['codeium#Complete']() end, { expr = true, silent = true })
vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
vim.keymap.set('i', '<c-.>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })

return {
	'Exafunction/codeium.vim',
	-- keys = {
	-- 	{ '<C-h>', function () return vim.fn['codeium#Complete']() end, { expr = true, silent = true, mode = { 'i' } } },
	-- 	{ '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true, mode = { 'i' } } },
	-- 	{ '<c-.>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true, mode = { 'i' } } },
	-- 	{ '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true, mode = { 'i' } } },
	-- 	{ '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true, mode = { 'i' } } },
	-- },
}