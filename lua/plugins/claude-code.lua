local M = {
	"coder/claudecode.nvim",
}

M.dependencies = {
	"folke/snacks.nvim",
}

M.module = false
M.cmd = {
	"ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel", "ClaudeCodeAdd",
	"ClaudeCodeSend", "ClaudeCodeTreeAdd", "ClaudeCodeStatus", "ClaudeCodeStart",
	"ClaudeCodeStop", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
}

M.opts = {
	terminal_cmd = nil, -- set to the output of `which claude` if Neovim can't find it
	terminal = {
		provider = "snacks",
		snacks_win_opts = {
			position = "float",
			width = 0.8,
			height = 0.8,
			border = "rounded",
			keys = {
				term_normal = false,
				claude_hide = { "<C-q>", function(self) self:hide() end, mode = "t", desc = "Hide Claude" },
			},
		},
	},
	diff_opts = {
		layout = "vertical",
		open_in_new_tab = false,
	},
}

M.config = function(_, opts)
	require("claudecode").setup(opts)
	require("which-key").add({
		{ "<leader>i", group = "A[I] / Claude" },
	})
end

M.keys = {
	{ "<leader>ic", "<cmd>ClaudeCode<CR>",              desc = "Toggle Claude Code" },
	{ "<leader>if", "<cmd>ClaudeCodeFocus<CR>",         desc = "Focus Claude Code" },
	{ "<leader>ir", "<cmd>ClaudeCode --resume<CR>",     desc = "Resume session" },
	{ "<leader>iC", "<cmd>ClaudeCode --continue<CR>",   desc = "Continue last session" },
	{ "<leader>im", "<cmd>ClaudeCodeSelectModel<CR>",   desc = "Select model" },
	{ "<leader>ib", "<cmd>ClaudeCodeAdd %<CR>",         desc = "Add current buffer" },
	{ "<leader>is", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection" },
	{ "<leader>is", "<cmd>ClaudeCodeTreeAdd<CR>", ft = "NvimTree", desc = "Add file from tree" },
	{ "<leader>ia", "<cmd>ClaudeCodeDiffAccept<CR>",    desc = "Accept diff" },
	{ "<leader>id", "<cmd>ClaudeCodeDiffDeny<CR>",      desc = "Deny diff" },
}

return M
