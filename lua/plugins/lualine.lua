-- Set lualine as statusline

local function codeium()
	local status_line = vim.api.nvim_call_function("codeium#GetStatusString", {})
	if status_line == " ON" then
		return " ✔ "
	elseif status_line == "OFF" then
		return " ❌"
	elseif status_line == " * " then
		return " ⏳"
	else
		return status_line
	end
end


return {
	'nvim-lualine/lualine.nvim',
	opts = {
		options = {
			icons_enabled = true,
			theme = 'onedark',
			component_separators = '|',
			section_separators = '',
		},
		sections = {
			lualine_y = { codeium },
		},
	},
}
