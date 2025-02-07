-- ChatGPT plugin
return {
	"jackMort/ChatGPT.nvim",
	-- enable = false,
	enabled = false,
	event = "VeryLazy",
	config = function()
		local home = vim.fn.expand("$HOME")
		require("chatgpt").setup({
			api_key_cmd = "gpg --decrypt " .. home .. "/.ssh/gpt-access-key.txt.gpg"
		})

		require("which-key").add({
			{ "cg",  group = "ChatGPT" },
			{ "cgc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
			{
				mode = { "n", "v" },
				{ "cga", "<cmd>ChatGPTRun add_tests<CR>",                 desc = "Add Tests" },
				{ "cgd", "<cmd>ChatGPTRun docstring<CR>",                 desc = "Docstring" },
				{ "cge", "<cmd>ChatGPTEditWithInstruction<CR>",           desc = "Edit with instruction" },
				{ "cgf", "<cmd>ChatGPTRun fix_bugs<CR>",                  desc = "Fix Bugs" },
				{ "cgg", "<cmd>ChatGPTRun grammar_correction<CR>",        desc = "Grammar Correction" },
				{ "cgk", "<cmd>ChatGPTRun keywords<CR>",                  desc = "Keywords" },
				{ "cgl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
				{ "cgo", "<cmd>ChatGPTRun optimize_code<CR>",             desc = "Optimize Code" },
				{ "cgr", "<cmd>ChatGPTRun roxygen_edit<CR>",              desc = "Roxygen Edit" },
				{ "cgs", "<cmd>ChatGPTRun summarize<CR>",                 desc = "Summarize" },
				{ "cgt", "<cmd>ChatGPTRun translate<CR>",                 desc = "Translate" },
				{ "cgx", "<cmd>ChatGPTRun explain_code<CR>",              desc = "Explain Code" },
			},
		})
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim"
	},
}
