-- Theme inspired by Atom
local M = {
	'navarasu/onedark.nvim',
	-- enabled = false,
}

M.priority = 1000

M.config = function()
	vim.cmd.colorscheme 'onedark'
end

return M
