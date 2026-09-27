vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = true })
vim.keymap.set('t', '<C-r>', function()
	local register = vim.fn.getcharstr()
	if register:match('^[%w"*+/:.%%#=_%-]$') then
		vim.api.nvim_paste(vim.fn.getreg(register), false, -1)
	end
end, { buffer = true, desc = 'Paste register' })
