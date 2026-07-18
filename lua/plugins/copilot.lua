local M = {
	{
		"zbirenbaum/copilot.lua",
	},
	{
		"zbirenbaum/copilot-cmp",
	},
}

M[1].enabled = false
M[1].build = ":Copilot auth"
M[1].cmd = "Copilot"
M[1].event = "InsertEnter"
M[1].main = "copilot"
M[1].opts = {
	panel = {
		enabled = true,
		auto_refresh = true,
		keymap = {
			jump_next = "<c-j>",
			jump_prev = "<c-k>",
			accept = "<c-a>",
			refresh = "r",
			open = "<M-CR>",
		},
		layout = {
			position = "bottom", -- | top | left | right
			ratio = 0.4,
		},
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<c-a>",
			accept_word = false,
			accept_line = false,
			next = "<c-j>",
			prev = "<c-k>",
			dismiss = "<C-e>",
		},
	},
}

M[2].enabled = false
M[2].after = { "copilot.lua" }
M[2].main = "copilot_cmp"
M[2].opts = {}

return M
