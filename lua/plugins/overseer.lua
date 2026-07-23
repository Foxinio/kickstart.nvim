local M = { "stevearc/overseer.nvim" }

M.keys = {
	{ "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Toggle Overseer" },
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

			["<C-o>"] = "keymap.open",
			["<CR>"] = "keymap.run_action",
			["P"] = {
				"keymap.open",
				opts = { dir = "float" },
				desc = "Open task output in float",
			},
			["<C-r>"] = { "keymap.run_action", opts = { action = "restart" }, desc = "Retry task" },
			["<C-w>"] = { "keymap.run_action", opts = { action = "watch" }, desc = "Watch task" },
		},
	},
	task_win = {
		border = "rounded",
		padding = 8,
		win_opts = {
			winblend = 0,
			winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
		},
	},
}

M.config = function(_, opts)
	require("overseer").setup(opts)

	vim.api.nvim_create_user_command("OverseerDisposeAll", function()
		require("plugin-utils.overseer").clear_list()
	end, {
		desc = "Dispose all Overseer tasks",
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "OverseerOutput",
		callback = function(args)
			local close_float = function()
				if vim.api.nvim_win_get_config(0).relative ~= "" then
					vim.cmd.close()
				end
			end

			vim.keymap.set("n", "q", close_float, {
				buffer = args.buf,
				desc = "Close preview",
			})
			vim.keymap.set("n", "<C-q>", close_float, {
				buffer = args.buf,
				desc = "Close preview",
			})
		end,
	})
end

return M
