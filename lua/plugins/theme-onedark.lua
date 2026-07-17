-- Theme inspired by Atom
return {
	'navarasu/onedark.nvim',
	-- enabled = false,
	priority = 1000,
	config = function()
		vim.cmd.colorscheme 'onedark'
	end,
}
