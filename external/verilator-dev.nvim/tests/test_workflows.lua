local root = dofile(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)) .. '/bootstrap.lua').root
local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. '/test_regress/t', 'p')
vim.fn.mkdir(directory .. '/dumps', 'p')
local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind) return kind == 'state' and directory .. '/state' or stdpath(kind) end
vim.cmd.cd(directory)
local telescope = require('telescope')
telescope.setup({ defaults = { preview = false } })
local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local overseer = require('overseer')
local tasks = {}
local new_task, open = overseer.new_task, overseer.open
overseer.new_task = function(options)
	tasks[#tasks + 1] = options
	return { start = function() end }
end
overseer.open = function() end
local function picker() return assert(state.get_current_picker(vim.api.nvim_get_current_buf())) end
local function select()
	local current = picker()
	assert(vim.wait(1000, function() return current.manager and current.manager:num_results() > 0 end))
	actions.select_default(current.prompt_bufnr)
	vim.wait(50, function() return false end)
end
local regression = require('verilator-dev.regression')
vim.fn.writefile({}, directory .. '/test_regress/t/t_example.py')
regression.run()
actions.close(picker().prompt_bufnr)
assert(#tasks == 0, 'Cancelled regression picker must not start a task')
vim.fn.mkdir(directory .. '/state', 'p')
vim.fn.writefile({ '--vlt --jobs 2' }, directory .. '/state/verilator-regress-args')
regression.run()
select()
assert(#tasks == 1 and tasks[1].cmd:find('--vlt --jobs 2', 1, true))
assert(tasks[1].env.FORCE_COLOR == '1' and tasks[1].strategy.use_terminal == false)
assert(tasks[1].components[1][1] == 'ansi_colorize')
assert(vim.tbl_contains(tasks[1].components, 'on_exit_set_status'))
assert(vim.tbl_contains(tasks[1].components, 'on_complete_notify'))
overseer.new_task, overseer.open = new_task, open

local ast = require('verilator-dev.ast')
local executable, system, ui_open, notify = vim.fn.executable, vim.system, vim.ui.open, vim.notify
local messages, rendered, opened = {}, {}, {}
vim.notify = function(message) messages[#messages + 1] = tostring(message) end
vim.fn.executable = function(name) return name == 'astsee_verilator' and 1 or executable(name) end
vim.system = function(command, options, callback)
	rendered[#rendered + 1] = { command = command, options = options }
	callback({ code = 0 })
end
vim.ui.open = function(path) opened[#opened + 1] = path end
vim.fn.writefile({ '{}' }, directory .. '/dumps/Vtop_001_first.tree.json')
vim.fn.writefile({ '{}' }, directory .. '/dumps/Vtop_002_second.tree.json')
ast.html({ '1' })
ast.diff({ '1', '2' })
vim.wait(50, function() return false end)
assert(#rendered == 2 and #opened == 2)
assert(opened[1] == directory .. '/001_first.tree.html')
assert(opened[2] == directory .. '/001_first-002_second.diff.html')
assert(rendered[2].command[3]:find('--html', 1, true) and rendered[2].options.cwd == directory)
ast.diff({ '1' })
ast.html({ '1000' })
ast.html({ '3' })
assert(#messages == 3 and #rendered == 2)
vim.fn.executable = function() return 0 end
ast.html({ '1' })
assert(messages[#messages]:find('not available in PATH', 1, true))
vim.fn.executable = function() return 1 end

-- Exercise editable picker cancellation and carry its root/arguments into selection.
telescope.load_extension('editable')
local editable = telescope.extensions.editable
local editable_picker, captured = editable.editable_picker, nil
editable.editable_picker = function(options) captured = options end
ast.html({})
assert(captured and captured.initial_state.cwd == directory)
assert(#rendered == 2, 'Cancelled AST picker must not render')
local current = { cwd = directory .. '/dumps', cmd_args = { '--verbose', '--custom', 'argument with spaces' } }
local builtin = require('telescope.builtin')
local find_files, picker_options = builtin.find_files, nil
builtin.find_files = function(options) picker_options = options end
captured.open(current, { attach_mappings = function() end })
assert(picker_options.find_command()[1] == 'rg')
local selected_entry, close = state.get_selected_entry, actions.close
state.get_selected_entry = function() return { path = directory .. '/dumps/Vtop_001_first.tree.json' } end
actions.close = function() end
picker_options.attach_mappings(1, function() end)
actions.select_default(1)
vim.wait(50, function() return false end)
assert(#rendered == 3 and rendered[3].command[3]:find("'argument with spaces'", 1, true))
ast.html({})
assert(captured.initial_state.cwd == current.cwd and vim.deep_equal(captured.initial_state.cmd_args, current.cmd_args))
editable.editable_picker, builtin.find_files = editable_picker, find_files
state.get_selected_entry, actions.close = selected_entry, close

-- A missing optional feature dependency must become a command error notification.
local temporary_data = directory .. '/data'
vim.fn.stdpath = function(kind) return kind == 'data' and temporary_data or stdpath(kind) end
require('verilator-dev').setup()
local pick = require('verilator-dev.profiles').pick
require('verilator-dev.profiles').pick = function() error("module 'telescope.pickers' not found") end
vim.cmd('VerilatorDebugProfile')
assert(messages[#messages]:find('telescope.pickers', 1, true))
require('verilator-dev.profiles').pick = pick
vim.fn.executable, vim.system, vim.ui.open, vim.notify = executable, system, ui_open, notify
vim.fn.stdpath = stdpath
vim.cmd.cd('/tmp')
vim.fn.delete(directory, 'rf')
assert(package.loaded['dap-extra'] == nil)
assert(vim.fn.filereadable(require('verilator-dev').resource('scripts/capture.py')) == 1)
print('Regression arguments/cancellation and AST selection/rendering/error checks passed')
