-- Run with -u NONE; use real lazy loading with the host's three extracted specs.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h:h:h')
vim.go.loadplugins = true
vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/lazy.nvim')
local temporary = vim.fn.tempname()
local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind) return kind == 'data' and temporary or stdpath(kind) end
local dap = require('plugins.debug')
local extra = require('plugins.dap-extra')
local verilator = require('plugins.verilator-dev')
assert(not package.loaded['dap-extra.ui'] and not package.loaded['verilator-dev'])
local dependencies = stdpath('data') .. '/lazy'
local spec = { dap, extra, verilator }
for _, name in ipairs({
	'nvim-dap', 'nvim-dap-ui', 'nvim-nio', 'nvim-dap-virtual-text', 'telescope-dap.nvim',
	'mason.nvim', 'mason-nvim-dap.nvim', 'cmake-tools.nvim', 'overseer.nvim',
	'telescope.nvim', 'plenary.nvim', 'editable-telescope.nvim', 'term-color-parser.nvim',
}) do
	spec[#spec + 1] = { name = name, dir = dependencies .. '/' .. name }
end
dap.opts.ensure_installed = {}
extra.dir = root .. '/external/nvim-dap-extra.nvim'
verilator.dir = root .. '/external/verilator-dev.nvim'
require('lazy').setup(spec, {
	root = dependencies, lockfile = temporary .. '/lazy-lock.json',
	install = { missing = false }, checker = { enabled = false },
	change_detection = { enabled = false },
})
assert(not package.loaded['dap-extra'] and not package.loaded['verilator-dev'])
local verilator_first = vim.env.DEBUG_LOAD_ORDER == 'verilator'
if verilator_first then
	vim.cmd('DebugProfile load verilator')
	assert(package.loaded['verilator-dev'] and package.loaded['dap-extra'])
end
local mappings = {}
for _, mapping in ipairs(dap.keys) do mappings[mapping[1]] = mapping[2] end
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('\\dg', true, false, true), 'xt', false)
assert(vim.wait(1000, function() return package.loaded['dap-extra'] ~= nil end))
local debug = require('dap')
local called = false
local step = debug.step_over
debug.step_over = function() called = true end
mappings['<F10>']()
assert(called and package.loaded['dap-extra'])
if not verilator_first then
	assert(not package.loaded['verilator-dev'], 'Generic DAP must not load Verilator')
end
debug.step_over = step
vim.cmd('VerilatorDebugProfile load verilator')
assert(package.loaded['verilator-dev'])
local forwarded
vim.api.nvim_create_user_command('VerilatorDebugProfile', function(args) forwarded = args end,
	{ nargs = '*', bang = true, force = true })
vim.cmd('DebugProfile! save verilator')
assert(forwarded and forwarded.bang and vim.deep_equal(forwarded.fargs, { 'save', 'verilator' }))
local origin = vim.api.nvim_get_current_win()
local toggle = debug.toggle_breakpoint
debug.toggle_breakpoint = function() assert(vim.api.nvim_get_current_win() == origin) end
mappings['<leader>b']()
debug.toggle_breakpoint = toggle
local cmake, run_to_cursor = package.loaded['cmake-tools'], debug.run_to_cursor
local invoking = vim.api.nvim_get_current_win()
local buffer, cursor = vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)
for _, key in ipairs({ '<leader>dl', '<leader>df' }) do
	vim.api.nvim_set_current_win(invoking)
	local routed = false
	local function check_context()
		routed = true
		assert(vim.api.nvim_get_current_buf() == buffer)
		assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), cursor))
	end
	debug.run_to_cursor = check_context
	package.loaded['cmake-tools'] = { is_cmake_project = function() return true end, debug_current_file = check_context }
	mappings[key]()
	assert(routed)
end
package.loaded['cmake-tools'], debug.run_to_cursor = cmake, run_to_cursor
assert(vim.fn.exists(':DapClean') == 2 and vim.fn.exists(':VerilatorRegress') == 2)
vim.fn.delete(temporary, 'rf')
print('Combined lazy loading, generic DAP and DebugProfile forwarding passed')
