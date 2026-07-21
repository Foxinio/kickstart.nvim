local M = {
	"olimorris/codecompanion.nvim",
}

M.opts = {
	adapters = {
		acp = {
			codex = function()
				return require("codecompanion.adapters").extend("codex", {
					defaults = {
						auth_method = "openai-api-key", -- "openai-api-key"|"codex-api-key"|"chatgpt"
					},
					env = {
						OPENAI_API_KEY = "my-api-key",
					},
				})
			end,
		},
	},
}

M.keys = {
	{ '<leader>sc', "<cmd>CodeCompanionActions<CR>", desc = "CC Actions Selections" },
}

return M
