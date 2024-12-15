-- Useful plugin to show you pending keybinds.
return {
	'folke/which-key.nvim',
	opts = {
	},
	config = function()
		local presets = require("which-key.plugins.presets")
		presets.operators["v"] = nil
		require("which-key").add({
			{ "x", group = "Diagnostics" },
		})
	end,
}
--
-- {
--   "folke/which-key.nvim",
--   event = "VeryLazy",
--   opts = {
--     -- your configuration comes here
--     -- or leave it empty to use the default settings
--     -- refer to the configuration section below
-- 		local presets = require("which-key.plugins.presets")
-- 		presets.operators["v"] = nil
--   },
--   keys = {
--     {
--       "<leader>?",
--       function()
--         require("which-key").show({ global = false })
--       end,
--       desc = "Buffer Local Keymaps (which-key)",
--     },
--   },
-- }
