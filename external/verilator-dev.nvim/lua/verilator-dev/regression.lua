local M = {}

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
						env = require("verilator-dev.tasks").environment(),
						components = require("verilator-dev.tasks").components(),
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

return M
