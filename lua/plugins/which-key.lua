-- Useful plugin to show you pending keybinds.
return {
	'folke/which-key.nvim',
	opts = {
	},
	config = function ()
		local presets = require("which-key.plugins.presets")
		presets.operators["v"] = nil
		require("which-key").register({
			x = {
				name = "Diagnostics",
			}
		})
	end,
}
