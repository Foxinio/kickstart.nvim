-- Set lualine as statusline

local function windsurf()
	local status = require('codeium.virtual_text').status_string()
	if status == " ON" then
		return " ✔ "
	elseif status == "OFF" then
		return " ❌"
	elseif status == " * " then
		return " ⏳"
	else
		return status
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
			lualine_y = { windsurf },
			lualine_a = { "mode", { require("easy-dotnet.ui-modules.jobs").lualine } },
		},
	},
}
