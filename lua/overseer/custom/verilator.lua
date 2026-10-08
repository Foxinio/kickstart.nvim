local M = {}
local ast_root
local ast_args = { "--verbose" }

function M.run()
	local state_dir = vim.fn.stdpath("state")
	local args_path = state_dir .. "/verilator-regress-args"
	local flags = ""
	local file, err, code = io.open(args_path, "r")
	if file then
		local contents, read_err = file:read("*a")
		file:close()
		if contents then
			flags = contents
		else
			vim.notify("Could not read Verilator args: " .. read_err, vim.log.levels.WARN)
		end
	elseif code ~= 2 then
		vim.notify("Could not read Verilator args: " .. err, vim.log.levels.WARN)
	end

	local root = vim.fn.getcwd()
	if vim.fn.isdirectory(root .. "/test_regress") == 0 then
		local dir = root
		while vim.fn.fnamemodify(dir, ":t") ~= "test_regress" do
			local parent = vim.fn.fnamemodify(dir, ":h")
			if parent == dir then
				vim.notify("VerilatorRegress requires cwd/test_regress or a cwd inside test_regress", vim.log.levels.WARN)
				return
			end
			dir = parent
		end
		root = vim.fn.fnamemodify(dir, ":h")
	end

	local tests = {}
	for _, path in ipairs(vim.fn.globpath(root .. "/test_regress/t", "t_*.py", false, true)) do
		if vim.fn.filereadable(path) == 1 then
			table.insert(tests, path)
		end
	end
	if #tests == 0 then
		vim.notify("No Verilator regression tests found", vim.log.levels.WARN)
		return
	end

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local config = require("telescope.config").values
	local function open(prompt)
		require("telescope.pickers").new({}, {
			prompt_title = "Verilator regression tests",
			cwd = root,
			default_text = prompt or "",
			finder = require("telescope.finders").new_table({
				results = tests,
				entry_maker = function(path)
					local name = vim.fn.fnamemodify(path, ":t")
					return { value = path, path = path, filename = path, display = name, ordinal = name }
				end,
			}),
			sorter = config.generic_sorter({}),
			previewer = config.file_previewer({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if not entry then
						return
					end
					local saved, save_err = pcall(function()
						vim.fn.mkdir(state_dir, "p")
						local output = assert(io.open(args_path, "w"))
						local written, write_err = output:write(flags)
						local closed, close_err = output:close()
						assert(written, write_err)
						assert(closed, close_err)
					end)
					if not saved then
						vim.notify("Could not save Verilator args: " .. save_err, vim.log.levels.WARN)
					end
					local overseer = require("overseer")
					overseer.new_task({
						name = vim.fn.fnamemodify(entry.value, ":t"),
						cwd = root,
						cmd = 'unset VERILATOR_ROOT; PATH="/usr/bin:$PATH" ' .. vim.fn.shellescape(entry.value)
							.. (flags ~= "" and " " .. flags or ""),
						strategy = { "jobstart", use_terminal = false },
					}):start()
					overseer.open({ enter = false })
				end)
				map({ "i", "n" }, "<C-a>", function()
					local search = action_state.get_current_picker(prompt_bufnr):_get_prompt()
					actions.close(prompt_bufnr)
					vim.schedule(function()
						vim.ui.input({ prompt = "Verilator args: ", default = flags }, vim.schedule_wrap(function(input)
							if input ~= nil then
								flags = input
							end
							open(search)
						end))
					end)
				end)
				return true
			end,
		}):find()
	end
	open()
end

local function ast_html(numbers, diff)
	local count = diff and 2 or 1
	if #numbers ~= 0 and #numbers ~= count then
		vim.notify(diff and "Usage: VerilatorDiff [num1 num2]" or "Usage: VerilatorHtml [num]", vim.log.levels.ERROR)
		return
	end
	for index, number in ipairs(numbers) do
		if not number:match("^%d+$") or tonumber(number) > 999 then
			vim.notify("AST dump numbers must be integers from 0 to 999", vim.log.levels.ERROR)
			return
		end
		numbers[index] = string.format("%03d", tonumber(number))
	end
	if vim.fn.executable("astsee_verilator") == 0 then
		vim.notify("astsee_verilator is not available in PATH", vim.log.levels.ERROR)
		return
	end

	local cwd = vim.fn.getcwd()
	local matches = {}
	for _, number in ipairs(numbers) do
		local pattern = "_" .. number .. "_.*%.tree%.json$"
		local paths = vim.fs.find(function(name)
			return name:lower():match(pattern) ~= nil
		end, { path = cwd, type = "file", limit = math.huge })
		if #paths == 0 then
			vim.notify("No AST tree dump found for " .. number .. " in " .. cwd, vim.log.levels.ERROR)
			return
		end
		table.sort(paths)
		table.insert(matches, paths)
	end
	local function format_args(args)
		return table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
	end
	local function render(selected, args)
		local paths, names = {}, {}
		for _, path in ipairs(selected) do
			table.insert(paths, vim.fn.shellescape(path))
			local name = vim.fn.fnamemodify(path, ":t")
			table.insert(names, name:match(".*_(%d%d%d_[%a%-]*)%.tree%.json$") or name:gsub("%.[tT][rR][eE][eE]%.[jJ][sS][oO][nN]$", ""))
		end
		local output = cwd .. "/" .. table.concat(names, "-") .. (diff and ".diff.html" or ".tree.html")
		local command = "astsee_verilator " .. table.concat(paths, " ") .. " --html " .. format_args(args)
			.. " > " .. vim.fn.shellescape(output)
		vim.system({ "sh", "-c", command }, { cwd = cwd, text = true }, vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				vim.notify("astsee_verilator failed: " .. (result.stderr or tostring(result.code)), vim.log.levels.ERROR)
				return
			end
			local _, err = vim.ui.open(output)
			if err then
				vim.notify(err, vim.log.levels.ERROR)
			end
		end))
	end
	local function select_path(index, selected, state, interactive)
		if index > count then
			render(selected, state.cmd_args)
		elseif not interactive and matches[index] and #matches[index] == 1 then
			selected[index] = matches[index][1]
			select_path(index + 1, selected, state, false)
		else
			local telescope = require("telescope")
			telescope.load_extension("editable")
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local number = numbers[index] or "[0-9][0-9][0-9]"
			telescope.extensions.editable.editable_picker({
				picker_opts = { cwd = state.cwd },
				initial_state = state,
				cmd_args_prompt = "astsee flags: ",
				parse_cmd_args = require("editable-telescope.args").split,
				format_cmd_args = format_args,
				prompt_title = function(current)
					return "Select AST dump " .. (numbers[index] or (index .. "/" .. count)) .. " (" .. current.cwd .. ")"
				end,
				open = function(current, picker_opts)
					ast_root, ast_args = current.cwd, current.cmd_args
					picker_opts.find_command = function()
						return { "rg", "--files", "--hidden", "--no-ignore", "--iglob", "*_" .. number .. "_*.tree.json" }
					end
					local attach_mappings = picker_opts.attach_mappings
					picker_opts.attach_mappings = function(prompt_bufnr, map)
						attach_mappings(prompt_bufnr, map)
						actions.select_default:replace(function()
							local entry = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if entry then
								local next_selected = vim.list_slice(selected)
								next_selected[index] = entry.path
								vim.schedule(function()
									select_path(index + 1, next_selected, current, true)
								end)
							end
						end)
						return true
					end
					require("telescope.builtin").find_files(picker_opts)
				end,
			})
		end
	end
	select_path(1, {}, { cwd = ast_root or cwd, cmd_args = ast_args }, false)
end

function M.html(numbers)
	ast_html(numbers, false)
end

function M.diff(numbers)
	ast_html(numbers, true)
end

return M
