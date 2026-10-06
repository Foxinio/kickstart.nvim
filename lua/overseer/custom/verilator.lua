local M = {}
local flags = ""

function M.run()
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
	if #numbers ~= (diff and 2 or 1) then
		vim.notify(diff and "Usage: VerilatorDiff num1 num2" or "Usage: VerilatorHtml num", vim.log.levels.ERROR)
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
	local matches, selected = {}, {}
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
	local function render()
		local paths, names = {}, {}
		for _, path in ipairs(selected) do
			table.insert(paths, vim.fn.shellescape(path))
			local name = vim.fn.fnamemodify(path, ":t")
			table.insert(names, name:match(".*_(%d%d%d_[%a%-]*)%.tree%.json$") or name:gsub("%.[tT][rR][eE][eE]%.[jJ][sS][oO][nN]$", ""))
		end
		local output = cwd .. "/" .. table.concat(names, "-") .. (diff and ".diff.html" or ".tree.html")
		local command = "astsee_verilator " .. table.concat(paths, " ") .. " --html --verbose > " .. vim.fn.shellescape(output)
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
	local function select_path(index)
		if index > #matches then
			render()
		elseif #matches[index] == 1 then
			selected[index] = matches[index][1]
			select_path(index + 1)
		else
			require("telescope").load_extension("ui-select")
			vim.ui.select(matches[index], {
				prompt = "Select AST dump " .. numbers[index],
				format_item = function(path) return vim.fs.relpath(cwd, path) end,
			}, vim.schedule_wrap(function(path)
				if path then
					selected[index] = path
					select_path(index + 1)
				end
			end))
		end
	end
	select_path(1)
end

function M.html(numbers)
	ast_html(numbers, false)
end

function M.diff(numbers)
	ast_html(numbers, true)
end

return M
