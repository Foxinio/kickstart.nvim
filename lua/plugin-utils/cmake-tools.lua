local M = {}

local function result_ok(result)
	return result and (result.code == 0 or (type(result.is_ok) == "function" and result:is_ok()))
end

local function get_config(cmake_tools)
	local config = cmake_tools.get_config()
	if type(config.update_build_directory) == "function" then
		config:update_build_directory()
	end

	return config
end

local function is_cmake_file_api_json_error(err)
	return type(err) == "string" and err:find("cmake%-tools/config%.lua") and err:find("invalid token")
end

local function clear_cmake_file_api_reply(config)
	local reply_directory = tostring(config.reply_directory or "")
	if reply_directory == "" or not reply_directory:find("%.cmake/api/v1/reply", 1, false) then
		return
	end

	vim.fn.delete(reply_directory, "rf")
end

local function run_with_codemodel_retry(cmake_tools, action, opts)
	local ok, err = pcall(action, opts)
	if ok then
		return
	end

	if not is_cmake_file_api_json_error(err) then
		error(err)
	end

	local config = get_config(cmake_tools)
	clear_cmake_file_api_reply(config)
	vim.notify("CMake file-api reply was invalid; regenerating project.", vim.log.levels.WARN)

	cmake_tools.generate({ bang = false, fargs = {} }, function(result)
		if not result_ok(result) then
			return
		end

		local retry_ok, retry_err = pcall(action, opts)
		if not retry_ok then
			vim.notify(retry_err, vim.log.levels.ERROR, { title = "CMakeTools" })
		end
	end)
end

local function list_tests(cmake_tools, callback)
	local config = get_config(cmake_tools)
	local types = require("cmake-tools.types")

	local ct = config:get_codemodel_targets()
	if not config:has_build_directory() or ct.code ~= types.SUCCESS then
		cmake_tools.generate({ bang = false, fargs = {} }, function(result)
			if result_ok(result) then
				list_tests(cmake_tools, callback)
			end
		end)
		return
	end

	require("cmake-tools.test.ctest").list_all_tests(config:build_directory_path(), nil, callback)
end

local function test_matches(regex, test_name)
	if not regex or regex == "" then
		return true
	end

	local ok, result = pcall(function()
		return vim.regex(regex):match_str(test_name) ~= nil
	end)
	return ok and result
end

local function run_tests_matching(cmake_tools, regex)
	local config = get_config(cmake_tools)
	local args = {
		"--test-dir",
		config:build_directory_path(),
		"--output-on-failure",
	}

	if regex and regex ~= "" then
		vim.list_extend(args, { "-R", regex })
	end

	local const = require("cmake-tools.const")
	local utils = require("cmake-tools.utils")
	utils.run(
		const.ctest_command,
		config.env_script,
		cmake_tools.get_build_environment(),
		args,
		config.cwd,
		config.runner,
		nil
	)
end

function M.select_test_regex(cmake_tools, initial_regex)
	list_tests(cmake_tools, function(tests)
		if #tests == 0 then
			vim.notify("No CTest tests found", vim.log.levels.WARN)
			return
		end

		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		local finders = require("telescope.finders")
		local pickers = require("telescope.pickers")
		local sorters = require("telescope.sorters")

		pickers
			.new({}, {
				prompt_title = "CTest -R",
				default_text = initial_regex or "",
				finder = finders.new_dynamic({
					fn = function(prompt)
						local matches = {}
						for _, test in ipairs(tests) do
							if test_matches(prompt, test.name) then
								table.insert(matches, test.name)
							end
						end
						return matches
					end,
				}),
				sorter = sorters.empty(),
				attach_mappings = function(prompt_bufnr, map)
					local run_prompt = function()
						local regex = action_state.get_current_line()
						actions.close(prompt_bufnr)
						run_tests_matching(cmake_tools, regex)
					end

					map("i", "<CR>", run_prompt)
					map("n", "<CR>", run_prompt)
					return true
				end,
			})
			:find()
	end)
end

function M.build_single_target(cmake_tools, opts)
	if not cmake_tools.is_cmake_project() then
		vim.notify("Not a CMake project", vim.log.levels.WARN, { title = "CMakeTools" })
		return
	end

	opts = opts or {}
	opts.fargs = opts.fargs or {}
	cmake_tools.quick_build(opts)
end

function M.run(cmake_tools, opts)
	run_with_codemodel_retry(cmake_tools, cmake_tools.run, opts)
end

function M.run_current_file(cmake_tools, opts)
	run_with_codemodel_retry(cmake_tools, cmake_tools.run_current_file, opts)
end

return M
