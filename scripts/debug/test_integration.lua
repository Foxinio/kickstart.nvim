-- MODE=compiler|simulation nvim --headless -u NONE -i NONE -l scripts/debug/test_integration.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
local data = vim.fn.stdpath('data')
for _, dir in ipairs(vim.fn.globpath(data .. '/lazy', '*', false, true)) do vim.opt.rtp:append(dir) end
vim.env.PATH = data .. '/mason/bin:' .. vim.env.PATH
require('mason').setup()
require('telescope').setup()
require('overseer').setup({ output = { use_terminal = false } })
require('plugins.debug').config(nil, { ensure_installed = {}, handlers = {} })
local profiles = require('plugin-utils.debug-profiles')
local debug = require('plugin-utils.verilator-debug')
local dap = require('dap')
local profile = profiles.load('verilator')
if vim.env.VERILATOR_DEBUG_BINARY then profile.program = vim.env.VERILATOR_DEBUG_BINARY end
local _, root = profiles.resolve(profile)
profile.regress_args = { '--vlt', '--obj-suffix=-nvim-debug-check' }
local simulation = vim.env.MODE == 'simulation'
if simulation then profile.extra_args = {} end
local failure
local notify = vim.notify
vim.notify = function(message, level, ...)
	if level == vim.log.levels.ERROR then failure = tostring(message) end
	return notify(message, level, ...)
end
local stops = 0
dap.listeners.after.event_stopped['integration'] = function() stops = stops + 1 end
local source = root .. '/src/Verilator.cpp'
if not simulation then
	local bufnr = vim.fn.bufadd(source)
	require('dap.breakpoints').set({}, bufnr, 883)
end
debug.regression(simulation and 't_EXAMPLE' or 't_class_extends_pkg_bad', simulation)
assert(vim.wait(180000, function() return stops > 0 or failure end, 100), 'No initial DAP stop; inspect Overseer output and dap.log')
assert(not failure, failure)
local session = assert(dap.session())
assert(vim.wait(10000, function() return session.current_frame ~= nil end, 50), 'Stopped frame did not load')
assert(vim.uv.fs_realpath(session.config.cwd) == vim.uv.fs_realpath(root .. '/test_regress'))
assert(session.config.environment)
local callbacks, errors = 0, {}
local names = simulation and { 'show args' } or {
	'help pn', 'help pnt', 'help jstash', 'help js', 'help jtree', 'help jt', 'help dtf', 'help watchedit', 'help proot',
}
for _, command in ipairs(names) do
	session:evaluate({ expression = '-exec ' .. command, context = 'repl' }, function(err)
		if err then errors[#errors + 1] = tostring(err) end
		callbacks = callbacks + 1
	end)
end
assert(vim.wait(10000, function() return callbacks == #names end, 50))
assert(#errors == 0, table.concat(errors, '\n'))
if not simulation then
	dap.continue()
	assert(vim.wait(10000, function() return stops > 1 end, 50), 'Active source breakpoint was not hit')
end
dap.terminate()
assert(vim.wait(10000, function() return dap.session() == nil end, 50))
print((simulation and 'Simulation' or 'Compiler') .. ' capture, DAP launch, helpers and breakpoint integration passed')
