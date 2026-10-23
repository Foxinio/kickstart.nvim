local M = {}
local profiles = require('plugin-utils.debug-profiles')
local config_dir = vim.fn.stdpath('config')
local capture_task

local function guarded(callback)
	return function(...)
		local ok, err = pcall(callback, ...)
		if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
	end
end

local function append(first, second)
	local result = vim.deepcopy(first or {})
	vim.list_extend(result, second or {})
	return result
end

function M.configuration(profile, record)
	local program, root, cwd = profiles.resolve(profile)
	record = record or profile.replay
	local simulation = record and record.simulation
	local environment = vim.tbl_extend('force', record and record.environment or {}, profile.environment or {})
	environment.VERILATOR_ROOT = root
	environment.VERILATOR_BIN = program
	local commands = {
		'set print max-depth 1', 'set history save on',
		'set history filename ' .. vim.fn.expand('~/.gdb/history.txt'),
		'set history size unlimited', '-enable-pretty-printing',
	}
	if not simulation then
		assert(vim.fn.filereadable(root .. '/src/.gdbinit') == 1, 'Missing Verilator helpers: ' .. root .. '/src/.gdbinit')
		vim.list_extend(commands, {
			'python import os; os.environ["VERILATOR_ROOT"] = ' .. vim.json.encode(root),
			'python gdb.execute("source " + ' .. vim.json.encode(root .. '/src/.gdbinit') .. ')',
			'catch throw',
			'python gdb.execute("define proot\\ncall AstNode::dumpTreeGdb(v3Global.m_rootp)\\nend")',
		})
	end
	vim.list_extend(commands, profile.setup_commands or {})
	local env = {}
	for name, value in pairs(environment) do table.insert(env, { name = name, value = value }) end
	return {
		name = simulation and 'Verilator simulation' or 'Verilator compiler',
		type = 'cppdbg', request = 'launch', MIMode = 'gdb',
		miDebuggerPath = vim.fn.exepath('gdb'), miDebuggerArgs = '-nx',
		program = record and record.program or program,
		cwd = record and record.cwd or cwd,
		args = append(record and record.args or profile.args, simulation and (profile.simulation_args or {}) or profile.extra_args),
		environment = env, externalConsole = false, stopAtEntry = true,
		setupCommands = vim.tbl_map(function(command) return { text = command, ignoreFailures = false } end, commands),
	}
end

local function launch(profile, record)
	assert(not require('dap').session(), 'Terminate the current debug session before launching another')
	require('dap').run(M.configuration(profile, record))
end

function M.binary(filename)
	profiles.with_current(function(profile)
		local function set(path)
			path = vim.fn.fnamemodify(vim.fn.expand(path), ':p')
			local updated = vim.tbl_extend('force', profile, { program = path })
			profiles.resolve(updated)
			profile.program, profile.replay = path, nil
			local _, name = profiles.get()
			profiles.save(name)
		end
		if filename ~= '' then return set(filename) end
		local ok, _, root = pcall(profiles.resolve, profile)
		root = ok and root or vim.fn.getcwd()
		local actions = require('telescope.actions')
		local state = require('telescope.actions.state')
		require('telescope.builtin').find_files({
			prompt_title = 'Verilator executable', cwd = root, hidden = true, no_ignore = true,
			attach_mappings = function(buf)
				actions.select_default:replace(function()
					local entry = state.get_selected_entry()
					actions.close(buf)
					if entry then vim.schedule(guarded(function() set(entry.path or root .. '/' .. entry.value) end)) end
				end)
				return true
			end,
		})
	end)
end

local function capture(profile, test, simulation)
	assert(not capture_task or not capture_task:is_running(), 'A regression capture is already running')
	assert(not require('dap').session(), 'Terminate the current debug session before capturing a test')
	local program, root = profiles.resolve(profile)
	assert(vim.fn.filereadable(root .. '/test_regress/driver.py') == 1, 'No regression driver under ' .. root)
	local python = vim.fn.exepath('python3')
	assert(python ~= '', 'python3 is required for regression capture')
	local directory = vim.fn.tempname()
	vim.fn.mkdir(directory, 'p', 448)
	local record_path = directory .. '/invocation.json'
	local settings = {
		program = program, root = root, test = test, simulation = simulation,
		extra_args = profile.extra_args or {}, environment = profile.environment or vim.empty_dict(),
		regress_args = profile.regress_args or { '--vlt' }, record = record_path,
	}
	local settings_path = directory .. '/config.json'
	vim.fn.writefile({ vim.json.encode(settings) }, settings_path)
	vim.uv.fs_chmod(settings_path, 384)
	local overseer = require('overseer')
	local task = overseer.new_task({
		name = 'Capture ' .. (simulation and 'model: ' or 'compiler: ') .. vim.fn.fnamemodify(test, ':t'),
		cmd = { python, config_dir .. '/scripts/debug/capture.py', 'runner', settings_path },
		cwd = root .. '/test_regress',
		strategy = { 'jobstart', use_terminal = false },
		components = { 'on_exit_set_status' },
	})
	capture_task = task
	task:subscribe('on_complete', function(_, status)
		capture_task = nil
		local ok, result = pcall(function()
			assert(status == 'SUCCESS' and vim.fn.filereadable(record_path) == 1,
				'No invocation captured; preparation failed, was cancelled, or the test was skipped. See Overseer output.')
			local record = vim.json.decode(table.concat(vim.fn.readfile(record_path), '\n'))
			profile.replay = record
			launch(profile, record)
		end)
		vim.fn.delete(directory, 'rf')
		if not ok then vim.notify(tostring(result), vim.log.levels.ERROR) end
	end)
	task:start()
	overseer.open({ enter = false })
end

function M.regression(test, simulation)
	profiles.with_current(function(profile)
		local _, root = profiles.resolve(profile)
		local function selected(filename)
			if not filename:match('%.py$') then filename = filename .. '.py' end
			if not filename:find('/') then filename = 't/' .. filename end
			local absolute = filename:sub(1, 1) == '/' and filename or root .. '/test_regress/' .. filename
			assert(vim.fn.filereadable(absolute) == 1, 'Test not found: ' .. absolute)
			capture(profile, vim.fn.fnamemodify(absolute, ':p'), simulation)
		end
		if test ~= '' then return selected(test) end
		local tests = vim.fn.globpath(root .. '/test_regress/t', 't_*.py', false, true)
		profiles.pick('Verilator ' .. (simulation and 'simulation' or 'compiler') .. ' regression', tests, selected, function(item) return item end)
	end)
end

function M.setup_repl()
	local repl = require('dap.repl')
	for command, alias in pairs({ into = 's', next_ = 'n', intoi = 'si', nexti = 'ni', out = 'fin', continue = 'c' }) do
		if not vim.tbl_contains(repl.commands[command], alias) then table.insert(repl.commands[command], alias) end
	end
	local function gdb(command, args)
		local session = require('dap').session()
		if not session or session.config.type ~= 'cppdbg' then
			repl.append('This command requires a GDB/cppdbg session')
			return
		end
		repl.execute('-exec ' .. command .. (args and args ~= '' and ' ' .. args or ''))
	end
	for _, name in ipairs({ 'pn', 'pnt', 'jstash', 'js', 'jtree', 'jt', 'dtf', 'watchedit', 'proot', 'p', 'i' }) do
		local command = name
		repl.commands.custom_commands[command] = function(args) gdb(command, args) end
	end
	repl.commands.custom_commands.gdb = function(args) gdb(args) end
end

function M.setup()
	profiles.setup()
	M.setup_repl()
	local commands = {
		DebugProfile = { callback = profiles.command, nargs = '*', bang = true },
		VerilatorDebugBinary = { callback = function(opts) M.binary(opts.args) end, nargs = '?', complete = 'file' },
		VerilatorDebug = { callback = function(opts)
			profiles.choose(opts.args, function(name) launch(profiles.load(name)) end)
		end, nargs = '?' },
		VerilatorDebugTest = { callback = function(opts) M.regression(opts.args, false) end, nargs = '?', complete = 'file' },
		VerilatorDebugSim = { callback = function(opts) M.regression(opts.args, true) end, nargs = '?', complete = 'file' },
	}
	for name, definition in pairs(commands) do
		vim.api.nvim_create_user_command(name, guarded(definition.callback), {
			nargs = definition.nargs, bang = definition.bang, complete = definition.complete, force = true,
		})
	end
	vim.api.nvim_create_autocmd('BufWritePost', {
		pattern = vim.fn.stdpath('data') .. '/verilator-debug/profiles/*.json',
		callback = guarded(function(opts)
			local _, name = profiles.get()
			if name == vim.fn.fnamemodify(opts.file, ':t:r') then profiles.load(name) end
		end),
	})
end

return M
