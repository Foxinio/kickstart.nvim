local M = { "civitasv/cmake-tools.nvim" }

M.module = false

M.cmd = {
	"CMakeBuild",
	"CMakeBuildCurrentFile",
	"CMakeBuildSingleTarget",
	"CMakeClean",
	"CMakeCloseExecutor",
	"CMakeCloseRunner",
	"CMakeDebug",
	"CMakeDebugCurrentFile",
	"CMakeGenerate",
	"CMakeInstall",
	"CMakeLaunchArgs",
	"CMakeOpenCache",
	"CMakeOpenExecutor",
	"CMakeOpenRunner",
	"CMakeQuickBuild",
	"CMakeQuickDebug",
	"CMakeQuickRun",
	"CMakeQuickStart",
	"CMakeRun",
	"CMakeRunCurrentFile",
	"CMakeRunSingleTarget",
	"CMakeRunTest",
	"CMakeRunTestRegex",
	"CMakeSelectBuildDir",
	"CMakeSelectBuildPreset",
	"CMakeSelectBuildTarget",
	"CMakeSelectBuildType",
	"CMakeSelectConfigurePreset",
	"CMakeSelectCwd",
	"CMakeSelectKit",
	"CMakeSelectLaunchTarget",
	"CMakeSelectTestPreset",
	"CMakeSettings",
	"CMakeShowTargetFiles",
	"CMakeStopExecutor",
	"CMakeStopRunner",
	"CMakeTargetSettings",
}

M.dependencies = {
	"nvim-lua/plenary.nvim",
	"stevearc/overseer.nvim",
	"Foxinio/term-color-parser.nvim",
}

local cmake_test_errorformat = table.concat({
	-- CTest prefixes test output with "<test-number>: ". If this is not
	-- consumed first, it can be parsed as part of the filename.
	[[%*\d:%\s%#%t%*\d %*\d:%*\d:%*\d.%*\d%\s%#%*\d%\s%#%f:%l]%\s%#%m]],
	[[%t%*\d %*\d:%*\d:%*\d.%*\d%\s%#%*\d%\s%#%f:%l]%\s%#%m]],
	[[%*\d:%\s%#%f:%l:%c:%m]],
	[[%f:%l:%c:%m]],
	vim.o.errorformat,
}, ",")

local function build_jobs()
	local uv = vim.uv or vim.loop
	local ok, jobs = pcall(function()
		return uv.available_parallelism and uv.available_parallelism() or #uv.cpu_info()
	end)
	return tostring(ok and jobs and jobs > 0 and jobs or 4)
end

local overseer_opts = {
	new_task_opts = {
		strategy = {
			"jobstart",
			use_terminal = false,
		},
		components = {
			"force_color",
			{ "ansi_colorize", mode = "conceal", on = "output" },
			"strip_ansi_lines",
			{
				"on_output_quickfix",
				errorformat = cmake_test_errorformat,
				open = false,
				open_on_match = false,
				open_on_exit = "never",
				open_height = 10,
				items_only = true,
				tail = true,
			},
			"on_exit_set_status",
			{
				"on_complete_notify",
				statuses = { "SUCCESS", "FAILURE" },
				system = "never",
			},
			{
				"on_complete_dispose",
				timeout = 900,
				require_view = { "SUCCESS", "FAILURE" },
			},
		},
	},
	on_new_task = function()
		require("overseer").open({ enter = false })
	end,
}

M.opts = {
	cmake_build_directory = "build",
	cmake_generate_options = {
		"-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
		"-DCMAKE_COLOR_DIAGNOSTICS=ON",
		"-DCMAKE_C_FLAGS_INIT=-fdiagnostics-color=always",
		"-DCMAKE_CXX_FLAGS_INIT=-fdiagnostics-color=always",
	},
	cmake_build_options = { "--parallel", build_jobs() },
	cmake_regenerate_on_save = false,
	cmake_notifications = {
		runner = { enabled = false },
		executor = { enabled = false },
	},
	cmake_dap_configuration = {
		type = "codelldb",
		request = "launch",
		stopOnEntry = false,
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
	local cmake_utils = require("plugin-utils.cmake-tools")

	cmake_tools.setup(opts)

	vim.api.nvim_create_user_command("CMakeRunTest", function(command_opts)
		command_opts.args = vim.trim("--output-on-failure " .. command_opts.args)
		cmake_tools.run_test(command_opts)
	end, {
		nargs = "*",
		desc = "CMake run test",
	})

	vim.api.nvim_create_user_command("CMakeRunTestRegex", function(command_opts)
		cmake_utils.select_test_regex(cmake_tools, command_opts.args)
	end, {
		nargs = "*",
		desc = "CMake run tests matching the Telescope prompt as a regex",
	})

	vim.api.nvim_create_user_command("CMakeBuild", function(command_opts)
		cmake_utils.build(cmake_tools, command_opts)
	end, {
		nargs = "*",
		bang = true,
		desc = "CMake build",
		force = true,
	})

	vim.api.nvim_create_user_command("CMakeBuildSingleTarget", function(command_opts)
		cmake_utils.build_single_target(cmake_tools, command_opts)
	end, {
		nargs = "?",
		desc = "CMake build a single target",
	})

	vim.api.nvim_create_user_command("CMakeRunSingleTarget", function(command_opts)
		cmake_utils.run_single_target(cmake_tools, command_opts)
	end, {
		nargs = "*",
		desc = "CMake run a single target",
	})

	vim.api.nvim_create_user_command("CMakeRun", function(command_opts)
		cmake_utils.run(cmake_tools, command_opts)
	end, {
		nargs = "*",
		desc = "CMake run",
		force = true,
	})

	vim.api.nvim_create_user_command("CMakeRunCurrentFile", function(command_opts)
		cmake_utils.run_current_file(cmake_tools, command_opts)
	end, {
		nargs = "*",
		desc = "CMake run current file",
		force = true,
	})
end

return M
