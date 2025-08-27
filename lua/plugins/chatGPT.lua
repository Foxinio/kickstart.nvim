-- ChatGPT plugin
return {
	"jackMort/ChatGPT.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim"
	},
	-- keys = {
	-- 	{ "hg",  group = "ChatGPT" },
	-- 	{ "hgc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
	-- 	{
	-- 		mode = { "n", "v" },
	-- 		{ "hga", "<cmd>ChatGPTRun add_tests<CR>",                 desc = "Add Tests" },
	-- 		{ "hgd", "<cmd>ChatGPTRun docstring<CR>",                 desc = "Docstring" },
	-- 		{ "hge", "<cmd>ChatGPTEditWithInstruction<CR>",           desc = "Edit with instruction" },
	-- 		{ "hgf", "<cmd>ChatGPTRun fix_bugs<CR>",                  desc = "Fix Bugs" },
	-- 		{ "hgg", "<cmd>ChatGPTRun grammar_correction<CR>",        desc = "Grammar Correction" },
	-- 		{ "hgk", "<cmd>ChatGPTRun keywords<CR>",                  desc = "Keywords" },
	-- 		{ "hgl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
	-- 		{ "hgo", "<cmd>ChatGPTRun optimize_code<CR>",             desc = "Optimize Code" },
	-- 		{ "hgr", "<cmd>ChatGPTRun roxygen_edit<CR>",              desc = "Roxygen Edit" },
	-- 		{ "hgs", "<cmd>ChatGPTRun summarize<CR>",                 desc = "Summarize" },
	-- 		{ "hgt", "<cmd>ChatGPTRun translate<CR>",                 desc = "Translate" },
	-- 		{ "hgx", "<cmd>ChatGPTRun explain_code<CR>",              desc = "Explain Code" },
	-- 	},
	-- },

	config = function()
		local configured = false
		vim.api.nvim_create_user_command("StartChatGPT", function()
			local home = vim.fn.expand("$HOME")
			require("chatgpt").setup({
				api_key_cmd = "gpg --decrypt " .. home .. "/.ssh/gpt_api_key.gpg",
				openai_params = {

				},
			})
			vim.notify("ChatGPT configured")
			configured = true
		end, {})

		local function safe_call(cmd)
			return function()
				if configured then
					vim.cmd(cmd)
				else
					vim.api.nvim_echo({
						{"ChatGPT is not configured"},
						{ "Call `StartChatGPT` to configure it" }}, false, {})
				end
			end
		end

		vim.api.nvim_create_user_command("ChatGPTConfigured", function()
      vim.notify(configured and "Chat is configured" or "Chat is not configured")
    end, {})

		require("which-key").add({
			{ "<leader>hg",  group = "ChatGPT" },
			{ "<leader>hgc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
			{
				mode = { "n", "v" },
				{ "<leader>hga", safe_call("<cmd>ChatGPTRun add_tests<CR>"),                 desc = "Add Tests" },
				{ "<leader>hgd", safe_call("<cmd>ChatGPTRun docstring<CR>"),                 desc = "Docstring" },
				{ "<leader>hge", safe_call("<cmd>ChatGPTEditWithInstruction<CR>"),           desc = "Edit with instruction" },
				{ "<leader>hgf", safe_call("<cmd>ChatGPTRun fix_bugs<CR>"),                  desc = "Fix Bugs" },
				{ "<leader>hgg", safe_call("<cmd>ChatGPTRun grammar_correction<CR>"),        desc = "Grammar Correction" },
				{ "<leader>hgk", safe_call("<cmd>ChatGPTRun keywords<CR>"),                  desc = "Keywords" },
				{ "<leader>hgl", safe_call("<cmd>ChatGPTRun code_readability_analysis<CR>"), desc = "Code Readability Analysis" },
				{ "<leader>hgo", safe_call("<cmd>ChatGPTRun optimize_code<CR>"),             desc = "Optimize Code" },
				{ "<leader>hgr", safe_call("<cmd>ChatGPTRun roxygen_edit<CR>"),              desc = "Roxygen Edit" },
				{ "<leader>hgs", safe_call("<cmd>ChatGPTRun summarize<CR>"),                 desc = "Summarize" },
				{ "<leader>hgt", safe_call("<cmd>ChatGPTRun translate<CR>"),                 desc = "Translate" },
				{ "<leader>hgx", safe_call("<cmd>ChatGPTRun explain_code<CR>"),              desc = "Explain Code" },
			},
		})
	end,
}
