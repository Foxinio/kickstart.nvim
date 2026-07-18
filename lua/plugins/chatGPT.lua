-- ChatGPT plugin
local M = {
	"jackMort/ChatGPT.nvim",
}
M.dependencies = {
	"MunifTanjim/nui.nvim",
	"nvim-lua/plenary.nvim",
	"folke/trouble.nvim",
	"nvim-telescope/telescope.nvim"
}

local configured = false

M.opts = {
	api_key_cmd = "gpg --decrypt " .. vim.fn.expand("$HOME") .. "/.ssh/gpt_api_key.gpg",
	openai_params = {},
}

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

M.config = function(_, opts)
	vim.api.nvim_create_user_command("StartChatGPT", function()
		if not configured then
			require("chatgpt").setup(opts)
			vim.notify("ChatGPT configured")
			configured = true
		else
			vim.notify("ChatGPT already configured")
		end
	end, {})

	vim.api.nvim_create_user_command("ChatGPTConfigured", function()
		vim.notify(configured and "Chat is configured" or "Chat is not configured")
	end, {})

	require("which-key").add({
		{ "<leader>hg",  group = "ChatGPT" },
	})
end

M.keys = {
	{ "<leader>hgc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
	{ "<leader>hga", safe_call("<cmd>ChatGPTRun add_tests<CR>"), mode = { "n", "v" }, desc = "Add Tests" },
	{ "<leader>hgd", safe_call("<cmd>ChatGPTRun docstring<CR>"), mode = { "n", "v" }, desc = "Docstring" },
	{ "<leader>hge", safe_call("<cmd>ChatGPTEditWithInstruction<CR>"), mode = { "n", "v" }, desc = "Edit with instruction" },
	{ "<leader>hgf", safe_call("<cmd>ChatGPTRun fix_bugs<CR>"), mode = { "n", "v" }, desc = "Fix Bugs" },
	{ "<leader>hgg", safe_call("<cmd>ChatGPTRun grammar_correction<CR>"), mode = { "n", "v" }, desc = "Grammar Correction" },
	{ "<leader>hgk", safe_call("<cmd>ChatGPTRun keywords<CR>"), mode = { "n", "v" }, desc = "Keywords" },
	{ "<leader>hgl", safe_call("<cmd>ChatGPTRun code_readability_analysis<CR>"), mode = { "n", "v" }, desc = "Code Readability Analysis" },
	{ "<leader>hgo", safe_call("<cmd>ChatGPTRun optimize_code<CR>"), mode = { "n", "v" }, desc = "Optimize Code" },
	{ "<leader>hgr", safe_call("<cmd>ChatGPTRun roxygen_edit<CR>"), mode = { "n", "v" }, desc = "Roxygen Edit" },
	{ "<leader>hgs", safe_call("<cmd>ChatGPTRun summarize<CR>"), mode = { "n", "v" }, desc = "Summarize" },
	{ "<leader>hgt", safe_call("<cmd>ChatGPTRun translate<CR>"), mode = { "n", "v" }, desc = "Translate" },
	{ "<leader>hgx", safe_call("<cmd>ChatGPTRun explain_code<CR>"), mode = { "n", "v" }, desc = "Explain Code" },
}

return M
