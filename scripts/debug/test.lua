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
fails(function() profiles.load('../escape') end)
fails(function() profiles.validate({ program = 'x', args = 'bad' }) end)
fails(function() profiles.validate({ program = 'x', environment = { BAD = 1 } }) end)
profiles.validate({ program = 'x', environment = { GOOD = 'valid' } })
fails(function() profiles.validate({ program = 'x', replay = {} }) end)
profile.extra_args = { '--debug', '-CFLAGS', 'argument with spaces' }
profiles.command({ fargs = { 'clone', 'copy' } })
assert(profiles.get().extra_args[3] == 'argument with spaces')
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
profile.program = checkout .. '/build/src/verilator_bin_dbg'
local _, resolved = profiles.resolve(profile)
assert(resolved == checkout, 'Prefer selected binary location over symlink target')
vim.cmd.cd('/tmp')
assert(select(2, profiles.resolve(profile)) == checkout)
profile.args = { 'manual.v' }
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
dap.session, repl.execute = session, execute

-- Exercise a real Telescope picker and cancel it without choosing anything.
require('telescope').setup({ defaults = { preview = false } })
profiles.choose(nil, function() error('Cancelled picker invoked callback') end)
local picker = require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
assert(picker)
require('telescope.actions').close(picker.prompt_bufnr)
vim.wait(100, function() return false end)
vim.fn.delete(temporary, 'rf')
print('Debug profile, configuration, REPL and Telescope checks passed')
