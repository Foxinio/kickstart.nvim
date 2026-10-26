local root = dofile(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)) .. '/bootstrap.lua').root
local temporary = vim.fn.tempname()
vim.fn.mkdir(temporary, 'p')
local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind) return kind == 'data' and temporary or stdpath(kind) end
local profiles = require('verilator-dev.profiles')
local debug = require('verilator-dev.debug')
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
for _, name in ipairs({ 'pn', 'pnt', 'jstash', 'js', 'jtree', 'jt', 'dtf', 'watchedit', 'proot' }) do
	assert(type(repl.commands.custom_commands[name]) == 'function')
end
local dap, forwarded = require('dap'), {}
local session, execute = dap.session, repl.execute
dap.session = function() return { config = { type = 'cppdbg' } } end
repl.execute = function(command) forwarded[#forwarded + 1] = command end
repl.commands.custom_commands.pnt('node with spaces')
assert(vim.deep_equal(forwarded, { '-exec pnt node with spaces' }))
dap.session, repl.execute = session, execute
-- Exercise a real Telescope picker and cancel it without choosing anything.
require('telescope').setup({ defaults = { preview = false } })
profiles.choose(nil, function() error('Cancelled picker invoked callback') end)
local picker = require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
assert(picker)
require('telescope.actions').close(picker.prompt_bufnr)
vim.wait(100, function() return false end)

local decorated = 0
require('verilator-dev').setup({ wrap_debug_action = function(callback)
	decorated = decorated + 1
	return callback
end })
assert(decorated == 6, 'Decorate only debug/profile command handlers')
assert(vim.fn.exists(':DebugProfile') == 0, 'Compatibility alias belongs to the host')
assert(#vim.api.nvim_get_autocmds({ group = 'verilator-dev-profiles' }) == 1)
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
	assert(options.cmd[2] == root .. '/scripts/capture.py')
	assert(options.env.PY_COLORS == '1' and options.strategy.use_terminal == false)
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
vim.fn.delete(temporary, 'rf')
assert(package.loaded['dap-extra'] == nil and package.loaded['dap-extra.ui'] == nil)
print('Standalone Verilator profiles, replay, capture and picker checks passed')
