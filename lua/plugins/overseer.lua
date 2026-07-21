local M = { "stevearc/overseer.nvim" }

M.keys = {
	{ "<leader>ot", "<cmd>OverseerToggle!<cr>", desc = "Toggle Overseer" },
	{ "<leader>oo", "<cmd>OverseerOpen!<cr>", desc = "Open Overseer" },
	{ "<leader>oc", "<cmd>OverseerClose<cr>", desc = "Close Overseer" },
	{ "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run Overseer task" },
	{ "<leader>os", "<cmd>OverseerShell<cr>", desc = "Run shell task" },
	{ "<leader>oa", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
}

M.opts = {
	form = {
		border = "rounded",
		height = 0.5,
		max_height = 0.5,
		max_width = 0.5,
		min_height = 1,
		min_width = 1,
		width = 0.5,
		win_opts = {
			winblend = 0,
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	},
	task_list = {
		keymaps = {
			["<C-f>"] = false,
			["<CR>"] = false,

			["<C-o>"] = "keymap.open",
			["o"] = "keymap.run_action",
			["P"] = {
				"keymap.open",
				opts = { dir = "float" },
				desc = "Open task output in float",
			},
		},
	},
	task_win = {
		border = "rounded",
		padding = 2,
		win_opts = {
			winblend = 0,
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	},
}

return M
