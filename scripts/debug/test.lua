-- Run: nvim --headless -u NONE -i NONE -l scripts/debug/test.lua
local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)
local data = vim.fn.stdpath('data')
for _, dir in ipairs(vim.fn.globpath(data .. '/lazy', '*', false, true)) do vim.opt.rtp:append(dir) end
local temporary = vim.fn.tempname()
vim.fn.mkdir(temporary, 'p')
local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind) return kind == 'data' and temporary or stdpath(kind) end
local profiles = require('plugin-utils.debug-profiles')
local debug = require('plugin-utils.verilator-debug')
local directory = temporary .. '/verilator-debug/profiles'
local function fails(callback) assert(not pcall(callback), 'Expected validation failure') end

profiles.setup()
assert(vim.deep_equal(profiles.names(), { 'verilator' }))
local profile = profiles.load('verilator')
assert(profile.program == nil and #profile.args == 0)
fails(function() profiles.load('../escape') end)
fails(function() profiles.validate({ program = 'x', args = 'bad' }) end)
fails(function() profiles.validate({ program = 'x', environment = { BAD = 1 } }) end)
profiles.validate({ program = 'x', environment = { GOOD = 'valid' } })
profile.replay = { program = '/old/checkout/model', args = { 'old-test.v' } }
profile.program = '/old/checkout/verilator_bin_dbg'
profile.extra_args = { '--debug', '-CFLAGS', 'argument with spaces' }
profiles.command({ fargs = { 'clone', 'copy' } })
assert(profiles.get().extra_args[3] == 'argument with spaces')
assert(profiles.get().replay == nil)
assert(profiles.get().program == nil)
assert(vim.json.decode(table.concat(vim.fn.readfile(directory .. '/copy.json'), '\n')).replay == nil)
vim.fn.writefile({ '{}' }, directory .. '/copy.json')
fails(function() profiles.save('copy') end)
profiles.save('copy', true)
assert(vim.deep_equal(profiles.load('copy').extra_args, profile.extra_args))

local checkout = temporary .. '/checkout'
vim.fn.mkdir(checkout .. '/build/src', 'p')
vim.fn.mkdir(checkout .. '/bin', 'p')
vim.fn.mkdir(checkout .. '/include', 'p')
vim.fn.mkdir(checkout .. '/src', 'p')
vim.fn.writefile({}, checkout .. '/bin/verilator')
vim.fn.writefile({}, checkout .. '/include/verilated.h')
vim.fn.writefile({}, checkout .. '/src/.gdbinit')
assert(vim.uv.fs_symlink('/bin/true', checkout .. '/build/src/verilator_bin_dbg'))
profiles.set_binary(checkout .. '/build/src/verilator_bin_dbg')
local _, resolved = profiles.resolve(profile)
assert(resolved == checkout, 'Prefer selected binary location over symlink target')
vim.cmd.cd('/tmp')
assert(select(2, profiles.resolve(profile)) == checkout)
vim.cmd.cd(checkout)
profiles.set_binary('build/src/verilator_bin_dbg')
assert(select(2, profiles.resolve(profile)) == checkout)
vim.fn.mkdir(temporary .. '/other/build/src', 'p')
vim.fn.mkdir(temporary .. '/other/bin', 'p')
vim.fn.mkdir(temporary .. '/other/include', 'p')
vim.fn.writefile({}, temporary .. '/other/bin/verilator')
vim.fn.writefile({}, temporary .. '/other/include/verilated.h')
assert(vim.uv.fs_symlink('/bin/true', temporary .. '/other/build/src/verilator_bin_dbg'))
vim.cmd.cd(temporary .. '/other')
assert(select(2, profiles.resolve(profile)) == temporary .. '/other', 'Relative binary must follow cwd')
vim.cmd.cd(checkout .. '/src')
profiles.set_binary('../build/src/verilator_bin_dbg')
assert(select(2, profiles.resolve(profile)) == checkout, 'Support paths outside cwd')
vim.cmd.cd(checkout)
profiles.set_binary('build/src/verilator_bin_dbg')
profiles.load('copy')
assert(select(2, profiles.resolve(profile)) == checkout, 'Loading profiles must not change the binary')
fails(function() profiles.set_binary('missing-binary') end)
assert(select(2, profiles.resolve(profile)) == checkout, 'Invalid override must preserve the binary')
local builtin = require('telescope.builtin')
local find_files, picker_cwd = builtin.find_files, nil
builtin.find_files = function(opts) picker_cwd = opts.cwd end
debug.binary('')
assert(picker_cwd == checkout, 'Binary picker must search Neovim cwd')
builtin.find_files = find_files
profile.args = { 'manual.v' }
profile.replay = { program = '/old/model', args = { 'old-test.v' }, simulation = true }
local config = debug.configuration(profile)
assert(vim.deep_equal(config.args, { 'manual.v', '--debug', '-CFLAGS', 'argument with spaces' }))
assert(config.cwd == checkout and config.stopAtEntry)
local model = { program = '/bin/true', cwd = '/tmp', args = { '+seed=7' }, simulation = true, environment = {} }
profile.simulation_args = { '+user=2' }
local sim = debug.configuration(profile, model)
assert(vim.deep_equal(sim.args, { '+seed=7', '+user=2' }))
assert(sim.cwd == '/tmp' and sim.program == '/bin/true')
for _, command in ipairs(sim.setupCommands) do assert(not command.text:find('catch throw', 1, true)) end

local picks = {}
local original_pick = profiles.pick
profiles.pick = function(title, _, callback) picks[#picks + 1] = { title = title, callback = callback } end
profiles.choose(nil, function() error('Cancellation must not invoke callback') end)
profiles.command({ fargs = {}, bang = false })
for _, action in ipairs({ 'load', 'edit', 'save', 'delete', 'clone' }) do profiles.command({ fargs = { action } }) end
assert(#picks == 7)
profiles.command({ fargs = { 'load', 'copy' } })
assert(#picks == 7, 'Explicit names must bypass selection')
profiles.pick = original_pick

debug.setup_repl()
local repl = require('dap.repl')
for _, name in ipairs({ 'pn', 'pnt', 'jstash', 'js', 'jtree', 'jt', 'dtf', 'watchedit', 'proot', 'p', 'i', 'gdb' }) do
	assert(type(repl.commands.custom_commands[name]) == 'function')
end
assert(vim.tbl_contains(repl.commands.into, 's') and vim.tbl_contains(repl.commands.out, 'fin'))
local dap, forwarded = require('dap'), {}
local session, execute = dap.session, repl.execute
dap.session = function() return { config = { type = 'cppdbg' } } end
repl.execute = function(command) forwarded[#forwarded + 1] = command end
repl.commands.custom_commands.pnt('node with spaces')
repl.commands.custom_commands.gdb('info locals')
assert(vim.deep_equal(forwarded, { '-exec pnt node with spaces', '-exec info locals' }))
local frames = {
	{ id = 100, name = 'inner', source = { path = 'inner.cpp' }, line = 10 },
	{ id = 7, name = 'caller', source = { path = 'caller.cpp' }, line = 20 },
	{ id = 42, name = 'main', source = { path = 'main.cpp' }, line = 30 },
}
local stopped = { stopped_thread_id = 1, threads = { { frames = frames } }, current_frame = frames[1] }
stopped._frame_set = function(self, frame) self.current_frame = frame end
dap.session = function() return stopped end
local original_append, output = repl.append, {}
repl.append = function(text) output[#output + 1] = text end
local commands = repl.commands.custom_commands
commands.up('2')
assert(stopped.current_frame == frames[3])
commands.down('')
assert(stopped.current_frame == frames[2])
commands.f('0')
assert(stopped.current_frame == frames[1])
commands.up('99')
assert(stopped.current_frame == frames[3])
commands.down('99')
assert(stopped.current_frame == frames[1])
commands.frame('2')
commands.frame('99')
commands.down('invalid')
assert(stopped.current_frame == frames[3])
commands.frame('')
assert(output[#output]:find('#2 main at main.cpp:30', 1, true))
output = {}
commands.backtrace('2')
assert(#output == 2 and output[1]:find('#0 inner', 1, true) and output[2]:find('#1 caller', 1, true))
dap.session = function() return nil end
commands.up('')
assert(output[#output]:find('requires a stopped session', 1, true))
repl.append = original_append
dap.session, repl.execute = session, execute

local original_buffer = vim.api.nvim_get_current_buf()
local prompt_buffer = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(prompt_buffer)
vim.bo[prompt_buffer].buftype = 'prompt'
vim.fn.prompt_setprompt(prompt_buffer, 'dap> ')
require('plugin-utils.debug-history').attach(prompt_buffer)
local function typed(text) vim.api.nvim_buf_set_lines(prompt_buffer, 0, -1, false, { 'dap> ' .. text }) end
local function key(lhs) return vim.fn.maparg(lhs, 'i', false, true).callback() end
local function line() return vim.api.nvim_get_current_line() end
for _, command in ipairs({ 'p node', 'up', 'p root', 'frame 0', 'p node->name()' }) do
	typed(command)
	assert(key('<CR>') == '<CR>')
end
typed('p ')
key('<Up>'); assert(line() == 'dap> p node->name()')
key('<Up>'); assert(line() == 'dap> p root')
key('<Up>'); assert(line() == 'dap> p node')
key('<Up>'); assert(line() == 'dap> p node')
key('<Down>'); assert(line() == 'dap> p root')
key('<Down>'); key('<Down>'); assert(line() == 'dap> p ')
typed('frame'); key('<Up>'); assert(line() == 'dap> frame 0')
typed('no match'); key('<Up>'); assert(line() == 'dap> no match')
typed(''); key('<Up>'); assert(line() == 'dap> p node->name()')
vim.api.nvim_set_current_buf(original_buffer)
vim.api.nvim_buf_delete(prompt_buffer, { force = true })

-- Exercise a real Telescope picker and cancel it without choosing anything.
require('telescope').setup({ defaults = { preview = false } })
profiles.choose(nil, function() error('Cancelled picker invoked callback') end)
local picker = require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
assert(picker)
require('telescope.actions').close(picker.prompt_bufnr)
vim.wait(100, function() return false end)

-- Debug panes and source jumps must leave the original tab's windows intact.
require('dapui').setup()
local debug_ui = require('plugin-utils.debug-ui')
vim.cmd('vsplit')
local original_tab = vim.api.nvim_get_current_tabpage()
local original_layout = vim.fn.winlayout()
local original_buffers = vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_tabpage_list_wins(original_tab))
local tab_count = #vim.api.nvim_list_tabpages()
debug_ui.open()
local debug_tab = vim.api.nvim_get_current_tabpage()
assert(debug_tab ~= original_tab and #vim.api.nvim_list_tabpages() == tab_count + 1)
debug_ui.open()
assert(#vim.api.nvim_list_tabpages() == tab_count + 1, 'Reuse the debugger tab')
vim.api.nvim_set_current_tabpage(original_tab)
local called = false
debug_ui.action(function(value)
	called = value
	assert(vim.api.nvim_get_current_tabpage() == debug_tab)
end)('forwarded')
assert(called == 'forwarded' and #vim.api.nvim_list_tabpages() == tab_count + 1)
local step_over = dap.step_over
dap.step_over = function() assert(vim.api.nvim_get_current_tabpage() == debug_tab) end
for _, mapping in ipairs(require('plugins.debug').keys) do
	if mapping[1] == '<F10>' then
		vim.api.nvim_set_current_tabpage(original_tab)
		mapping[2]()
	end
end
dap.step_over = step_over
vim.api.nvim_set_current_tabpage(original_tab)
local origin_buffer = vim.api.nvim_get_current_buf()
local origin_cursor = vim.api.nvim_win_get_cursor(0)
debug_ui.action(function()
	assert(vim.api.nvim_get_current_tabpage() == debug_tab)
	assert(vim.api.nvim_get_current_buf() == origin_buffer)
	assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), origin_cursor))
end, true)()
vim.api.nvim_set_current_tabpage(original_tab)
local target = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(target, 0, -1, false, { 'first', 'second' })
debug_ui.jump(target, 2, 1)
assert(vim.api.nvim_get_current_tabpage() == debug_tab and vim.api.nvim_get_current_buf() == target)
vim.api.nvim_set_current_tabpage(original_tab)
debug_ui.close()
assert(vim.api.nvim_get_current_tabpage() == original_tab)
assert(vim.deep_equal(vim.fn.winlayout(), original_layout))
assert(vim.deep_equal(vim.tbl_map(vim.api.nvim_win_get_buf, vim.api.nvim_tabpage_list_wins(original_tab)), original_buffers))
local mappings = {}
for _, mapping in ipairs(require('plugins.debug').keys) do mappings[mapping[1]] = mapping[2] end
local invoking = vim.api.nvim_get_current_win()
local toggle_breakpoint, set_breakpoint = dap.toggle_breakpoint, dap.set_breakpoint
local widgets = require('dap.ui.widgets')
local hover, input = widgets.hover, vim.fn.input
local local_calls = 0
local function local_action()
	local_calls = local_calls + 1
	assert(vim.api.nvim_get_current_win() == invoking)
	assert(vim.deep_equal(vim.fn.winlayout(), original_layout))
	assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), origin_cursor))
end
dap.toggle_breakpoint, dap.set_breakpoint, widgets.hover = local_action, local_action, local_action
vim.fn.input = function() return '' end
for _, key in ipairs({ '<leader>b', '<leader>B', '<leader>dK' }) do mappings[key]() end
assert(local_calls == 3)
dap.toggle_breakpoint, dap.set_breakpoint, widgets.hover, vim.fn.input = toggle_breakpoint, set_breakpoint, hover, input

local selected = { id = 9, source = { path = root .. '/scripts/debug/test.lua' }, line = 2, column = 1 }
dap.session = function() return { id = 1, current_frame = selected } end
mappings['<leader>dg']()
assert(vim.api.nvim_get_current_win() == invoking and vim.deep_equal(vim.fn.winlayout(), original_layout))
assert(vim.api.nvim_buf_get_name(0) == selected.source.path and vim.api.nvim_win_get_cursor(0)[1] == 2)
assert(dap.session().current_frame == selected)
selected.source = { sourceReference = 10 }
local adapter_buffer = vim.fn.bufadd('dap-src://1/10/')
vim.api.nvim_buf_set_lines(adapter_buffer, 0, -1, false, { 'adapter', 'source' })
mappings['<leader>dg']()
assert(vim.api.nvim_get_current_buf() == adapter_buffer)
selected.source = nil
mappings['<leader>dg']()
assert(vim.api.nvim_get_current_buf() == adapter_buffer)
dap.session = session
vim.api.nvim_win_set_buf(invoking, origin_buffer)

for _, key in ipairs({ '<leader>dl', '<leader>df' }) do
	vim.api.nvim_set_current_win(invoking)
	local old_run, old_cmake = dap.run_to_cursor, package.loaded['cmake-tools']
	local routed = false
	local function check_context()
		routed = true
		assert(vim.api.nvim_get_current_tabpage() == debug_tab)
		assert(vim.api.nvim_get_current_buf() == origin_buffer)
	end
	dap.run_to_cursor = check_context
	package.loaded['cmake-tools'] = { is_cmake_project = function() return true end, debug_current_file = check_context }
	mappings[key]()
	assert(routed)
	dap.run_to_cursor, package.loaded['cmake-tools'] = old_run, old_cmake
end
debug_ui.open()
local source_win = vim.api.nvim_get_current_win()
dap.repl.open()
for _, win in ipairs(vim.api.nvim_tabpage_list_wins(debug_tab)) do
	if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'dap-repl' then vim.api.nvim_set_current_win(win); break end
end
local repl_win = vim.api.nvim_get_current_win()
assert(vim.bo.filetype == 'dap-repl')
local function automatic_update()
	debug_ui.jump(target, 2, 1)
	assert(vim.api.nvim_get_current_win() == repl_win)
	assert(vim.api.nvim_win_get_buf(source_win) == target)
end
automatic_update()
stopped._frame_set = function(self, frame)
	self.current_frame = frame
	debug_ui.jump(target, 2, 1)
end
dap.session = function() return stopped end
commands.frame('0')
assert(stopped.current_frame == frames[1] and vim.api.nvim_get_current_win() == repl_win)
dap.session = session
debug_ui.open()
assert(vim.api.nvim_get_current_win() == repl_win)
vim.schedule(automatic_update)
vim.wait(50, function() return false end)
vim.api.nvim_set_current_win(invoking)
vim.schedule(function() debug_ui.jump(target, 1, 1) end)
vim.wait(50, function() return false end)
assert(vim.api.nvim_get_current_win() == source_win, 'Source actions must not restore old REPL focus')
vim.api.nvim_set_current_tabpage(debug_tab)
vim.cmd('tabclose')
debug_ui.open()
assert(vim.api.nvim_get_current_tabpage() ~= original_tab, 'Recreate a manually closed debugger tab')
debug_ui.close()
debug.setup()
local run, launches = dap.run, {}
dap.run = function(configuration)
	launches[#launches + 1] = vim.deepcopy(configuration)
	configuration.args[1] = 'adapter mutation'
end
profiles.set_binary(checkout .. '/build/src/verilator_bin_dbg')
vim.cmd('VerilatorDebugBin copy')
assert(#launches == 1)
local previous = vim.deepcopy(launches[1])
profiles.get().extra_args = { 'changed after launch' }
vim.cmd('VerilatorDebug')
vim.cmd('VerilatorDebug')
assert(#launches == 3 and vim.deep_equal(launches[2], previous) and vim.deep_equal(launches[3], previous))
vim.fn.mkdir(checkout .. '/test_regress/t', 'p')
vim.fn.writefile({}, checkout .. '/test_regress/driver.py')
vim.fn.writefile({}, checkout .. '/test_regress/t/focus.py')
local overseer = require('overseer')
local new_task, open = overseer.new_task, overseer.open
overseer.open = function() end
overseer.new_task = function(options)
	local settings = vim.json.decode(table.concat(vim.fn.readfile(options.cmd[4]), '\n'))
	local complete
	return {
		subscribe = function(_, _, callback) complete = callback end,
		start = function()
			vim.fn.writefile({ vim.json.encode(model) }, settings.record)
			complete(nil, 'SUCCESS')
		end,
	}
end
debug.regression('focus', true)
assert(#launches == 4 and launches[4].program == model.program)
assert(launches[4].args[1] == '+seed=7' and launches[4].cwd == '/tmp')
debug.repeat_last()
assert(#launches == 5 and vim.deep_equal(launches[5], launches[4]), 'Replay must retain the captured model invocation')
overseer.new_task, overseer.open = new_task, open
dap.run = run
debug_ui.setup()
local terminate, pending = dap.terminate, nil
local virtual_text = require('nvim-dap-virtual-text/virtual_text')
local namespace = vim.api.nvim_create_namespace('debug-cleanup-test')
local clear_text, clear_frames = virtual_text.clear_virtual_text, virtual_text.clear_last_frames
local clears = 0
virtual_text.clear_virtual_text = function()
	clears = clears + 1
	vim.api.nvim_buf_clear_namespace(target, namespace, 0, -1)
end
virtual_text.clear_last_frames = function() end
dap.terminate = function(options) pending = options.on_done end
debug_ui.open()
local cleanup_tab = vim.api.nvim_get_current_tabpage()
local breakpoint_count = vim.deepcopy(require('dap.breakpoints').get())
vim.api.nvim_buf_set_extmark(target, namespace, 0, 0, { virt_text = { { 'stale value' } } })
vim.api.nvim_set_current_win(invoking)
vim.cmd('DapClean')
assert(vim.api.nvim_get_current_win() == invoking)
assert(vim.api.nvim_tabpage_is_valid(cleanup_tab))
assert(#vim.api.nvim_tabpage_list_wins(cleanup_tab) == 1)
assert(#vim.api.nvim_buf_get_extmarks(target, namespace, 0, -1, {}) == 0)
assert(vim.deep_equal(require('dap.breakpoints').get(), breakpoint_count))
assert(clears == 1 and pending)
pending()
dap.terminate = function() end
vim.cmd('DapClean')
assert(clears == 3 and vim.api.nvim_get_current_win() == invoking)
dap.terminate = terminate
virtual_text.clear_virtual_text, virtual_text.clear_last_frames = clear_text, clear_frames
vim.fn.delete(temporary, 'rf')
print('Debug profile, configuration, REPL and Telescope checks passed')
