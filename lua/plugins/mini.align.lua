-- Align text interactively
-- https://github.com/echasnovski/mini.align

-- Config taken from
-- https://github.com/ruicsh/nvim-config/blob/main/lua/plugins/mini.align.lua

return {
	"echasnovski/mini.align",
	enabled = false,
-- TODO : Configure this
	opts = {
		mappings = {
			start = "ga",
			start_with_preview = "gA",
		},
	},
}
