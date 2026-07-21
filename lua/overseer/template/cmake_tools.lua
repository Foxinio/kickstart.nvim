local M = {
	name = "cmake-tools",
}

function M.result_ok(result)
	return result and (result.code == 0 or (type(result.is_ok) == "function" and result:is_ok()))
end

function M.append_all(target, source)
	for _, value in ipairs(source or {}) do
		table.insert(target, value)
	end
end

function M.cmake_command()
	local ok, const = pcall(require, "cmake-tools.const")
	if ok then
		return const.cmake_command
	end

	return "cmake"
end

function M.ctest_command()
	local ok, const = pcall(require, "cmake-tools.const")
	if ok then
		return const.ctest_command
	end

	return "ctest"
end

function M.get_config(cmake)
	local config = cmake.get_config()
	if type(config.update_build_directory) == "function" then
		config:update_build_directory()
	end

	return config
end

function M.build_args(cmake, target)
	local config = M.get_config(cmake)
	local args

	if config.build_preset then
		args = { "--build", "--preset", config.build_preset }
	else
		args = { "--build", config:build_directory_path() }
	end

	M.append_all(args, { "--target", target })

	if config.build_type then
		M.append_all(args, { "--config", config.build_type })
	end

	M.append_all(args, cmake.get_build_options())
	return args
end

function M.test_args(cmake)
	local config = M.get_config(cmake)
	local args

	if config.test_preset then
		args = { "--preset", config.test_preset }
	else
		args = { "--test-dir", config:build_directory_path() }
	end

	table.insert(args, "--output-on-failure")
	return args
end

function M.run_info(cmake, target)
	local config = M.get_config(cmake)
	local model_info = cmake.get_model_info()
	if not model_info or model_info.code then
		return nil
	end

	local target_info = model_info[target]
	if not target_info then
		return nil
	end

	local launch_target = config:get_launch_target_from_info(target_info)
	if not M.result_ok(launch_target) then
		return nil
	end

	local target_settings = config.target_settings[target] or {}
	return {
		cmd = launch_target.data,
		args = target_settings.args or {},
		cwd = cmake.get_launch_path(target),
		env = cmake.get_run_environment(target),
	}
end

function M.build_task(cmake, target)
	local config = M.get_config(cmake)

	return {
		name = "CMake: build " .. target,
		cmd = M.cmake_command(),
		args = M.build_args(cmake, target),
		cwd = config.cwd,
		env = cmake.get_build_environment(),
	}
end

function M.test_task(cmake)
	local config = M.get_config(cmake)

	return {
		name = "CMake: test all",
		cmd = M.ctest_command(),
		args = M.test_args(cmake),
		cwd = config.cwd,
		env = cmake.get_build_environment(),
	}
end

function M.run_task(cmake, target)
	local info = M.run_info(cmake, target)
	if not info then
		return {
			name = "CMake: run " .. target,
			cmd = "false",
		}
	end

	return vim.tbl_extend("force", {
		name = "CMake: run " .. target,
	}, info)
end

function M.build_templates(cmake, templates)
	local build_targets = cmake.get_build_targets()
	if not M.result_ok(build_targets) then
		return build_targets and build_targets.message or "Unable to get CMake build targets"
	end

	for index, target in ipairs(build_targets.data.targets or {}) do
		local display_target = build_targets.data.display_targets[index] or target
		table.insert(templates, {
			name = "CMake: build " .. target,
			desc = display_target,
			builder = function()
				return M.build_task(cmake, target)
			end,
		})
	end
end

function M.run_templates(cmake, templates)
	local launch_targets = cmake.get_launch_targets()
	if not M.result_ok(launch_targets) then
		return
	end

	for index, target in ipairs(launch_targets.data.targets or {}) do
		local display_target = launch_targets.data.display_targets[index] or target
		table.insert(templates, {
			name = "CMake: run " .. target,
			desc = display_target,
			builder = function()
				return M.run_task(cmake, target)
			end,
		})
	end
end

function M.generator()
	local ok, cmake = pcall(require, "cmake-tools")
	if not ok or not cmake.is_cmake_project() then
		return "Not a cmake-tools project"
	end

	local templates = {
		{
			name = "CMake: test all",
			builder = function()
				return M.test_task(cmake)
			end,
		},
	}

	local build_error = M.build_templates(cmake, templates)
	if build_error then
		return build_error
	end

	M.run_templates(cmake, templates)
	return templates
end

return M
