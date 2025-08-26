-- ChatGPT plugin
return {
	"jackMort/ChatGPT.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim"
	},

	enabled = true,
	config = function()
		vim.api.nvim_create_user_command("StartChatGPT", function()
			local home = vim.fn.expand("$HOME")
			require("chatgpt").setup({
				api_key_cmd = "gpg --decrypt " .. home .. "/.ssh/gpt_api_key.gpg",
				openai_params = {

				},
			})
			vim.notify("ChatGPT configured")
		end, {})

		require("which-key").add({
			{ "hg",  group = "ChatGPT" },
			{ "hgc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
			{
				mode = { "n", "v" },
				{ "hga", "<cmd>ChatGPTRun add_tests<CR>",                 desc = "Add Tests" },
				{ "hgd", "<cmd>ChatGPTRun docstring<CR>",                 desc = "Docstring" },
				{ "hge", "<cmd>ChatGPTEditWithInstruction<CR>",           desc = "Edit with instruction" },
				{ "hgf", "<cmd>ChatGPTRun fix_bugs<CR>",                  desc = "Fix Bugs" },
				{ "hgg", "<cmd>ChatGPTRun grammar_correction<CR>",        desc = "Grammar Correction" },
				{ "hgk", "<cmd>ChatGPTRun keywords<CR>",                  desc = "Keywords" },
				{ "hgl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
				{ "hgo", "<cmd>ChatGPTRun optimize_code<CR>",             desc = "Optimize Code" },
				{ "hgr", "<cmd>ChatGPTRun roxygen_edit<CR>",              desc = "Roxygen Edit" },
				{ "hgs", "<cmd>ChatGPTRun summarize<CR>",                 desc = "Summarize" },
				{ "hgt", "<cmd>ChatGPTRun translate<CR>",                 desc = "Translate" },
				{ "hgx", "<cmd>ChatGPTRun explain_code<CR>",              desc = "Explain Code" },
			},
		})
	end,
}
