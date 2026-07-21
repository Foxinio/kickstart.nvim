local M = { "civitasv/cmake-tools.nvim" }

M.dependencies = {
	"nvim-lua/plenary.nvim",
	"stevearc/overseer.nvim",
}

local overseer_opts = {
	new_task_opts = {
		strategy = {
			"jobstart",
			use_terminal = false,
		},
	},
	on_new_task = function()
		require("overseer").open({ enter = false, direction = "left" })
	end,
}

M.opts = {
	cmake_build_directory = "build",
	cmake_build_options = { "-j" },
	cmake_notifications = {
		runner = { enabled = false },
		executor = { enabled = false },
	},
	cmake_virtual_text_support = false,
	cmake_executor = {
		name = "overseer",
		opts = overseer_opts,
		default_opts = {
			quickfix = {
				show = "only_on_error",
			},
		},
	},
	cmake_runner = {
		name = "overseer",
		opts = overseer_opts,
	},
}

M.config = function(_, opts)
	local cmake_tools = require("cmake-tools")

	cmake_tools.setup(opts)

	vim.api.nvim_create_user_command("CMakeRunTest", function(command_opts)
		command_opts.args = vim.trim("--output-on-failure " .. command_opts.args)
		cmake_tools.run_test(command_opts)
	end, {
		nargs = "*",
		desc = "CMake run test",
	})
end

return M
