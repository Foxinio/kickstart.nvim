local M = {}

function M.continue_or_cmake_debug()
	local dap = require('dap')
	if dap.session() then
		dap.continue()
		return
	end

	local ok, cmake = pcall(require, "cmake-tools")
	if ok and cmake.is_cmake_project() and type(cmake.debug) == "function" then
		cmake.debug({ fargs = {} })
		return
	end

	dap.continue()
end

function M.cmake_quick_debug()
	local ok, cmake = pcall(require, "cmake-tools")
	if not ok or not cmake.is_cmake_project() or type(cmake.quick_debug) ~= "function" then
		vim.notify("CMake debug is only available inside a CMake project", vim.log.levels.WARN)
		return
	end

	cmake.quick_debug({ fargs = {} })
end

function M.cmake_debug_current_file()
	local ok, cmake = pcall(require, "cmake-tools")
	if not ok or not cmake.is_cmake_project() or type(cmake.debug_current_file) ~= "function" then
		vim.notify("CMake debug current file is only available inside a CMake project", vim.log.levels.WARN)
		return
	end

	cmake.debug_current_file({ fargs = {} })
end

local function executable_finder(opts, command)
	local make_entry = require('telescope.make_entry').gen_from_file(opts)
	local entries, job, closed, complete = {}, nil, false, false
	local emit, finish
	return setmetatable({
		close = function()
			closed = true
			if job and not complete then job:kill(15) end
		end,
	}, {
		__call = function(_, _, process_result, process_complete)
			emit, finish = process_result, process_complete
			for _, entry in ipairs(entries) do emit(entry) end
			if complete then
				finish()
			elseif not job then
				job = vim.system(command, { cwd = opts.cwd }, vim.schedule_wrap(function(result)
					if closed then return end
					complete = true
					if result.code ~= 0 then
						vim.notify('Executable search failed: ' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
					end
					for _, path in ipairs(vim.split(result.stdout or '', '\0', { plain = true, trimempty = true })) do
						local entry = make_entry(path)
						if entry then
							entry.index = #entries + 1
							entries[#entries + 1] = entry
							emit(entry)
						end
					end
					finish()
				end))
			end
		end,
	})
end

function M.select_executable(opts)
	opts = opts or {}
	return coroutine.create(function(co)
		local actions = require('telescope.actions')
		local state = require('telescope.actions.state')
		local done = false
		local function finish(value)
			if done then return end
			done = true
			vim.schedule(function()
				local ok, err = coroutine.resume(co, value)
				if not ok then vim.notify(err, vim.log.levels.ERROR) end
			end)
		end
		local function open(root)
			root = vim.fn.fnamemodify(root, ':p')
			if vim.fn.isdirectory(root) == 0 then
				vim.notify('Search root is not a directory: ' .. root, vim.log.levels.WARN)
				finish(require('dap').ABORT)
				return
			end
			require('telescope').extensions.editable.find_files({
				cwd = root,
				prompt_title = opts.bytecode and 'Select OCaml executable' or 'Select executable',
				previewer = false,
				hidden = true,
				find_command = function(picker_opts)
					local command = { 'find', '.', '-name', '.git', '-prune', '-o', '-type', 'f', '-executable' }
					if opts.bytecode then vim.list_extend(command, { '-name', '*.bc' }) end
					vim.list_extend(command, { '-print0' })
					-- Build a finder per root so search errors are visible and filenames stay NUL-delimited.
					picker_opts.finder = executable_finder(picker_opts, command)
					return command
				end,
				attach_mappings = function(bufnr, map)
					local function select()
						local entry = state.get_selected_entry()
						if not entry then return end
						local path = entry.path
						local stat = path and (vim.uv or vim.loop).fs_stat(path)
						if not stat or stat.type ~= 'file' or vim.fn.executable(path) ~= 1 then
							vim.notify('Executable is no longer available: ' .. tostring(path), vim.log.levels.WARN)
							return
						end
						actions.close(bufnr)
						finish(path)
					end
					local function cancel()
						actions.close(bufnr)
						finish(require('dap').ABORT)
					end
					actions.select_default:replace(select)
					actions.select_horizontal:replace(select)
					actions.select_vertical:replace(select)
					actions.select_tab:replace(select)
					map({ 'i', 'n' }, '<Esc>', cancel)
					map({ 'i', 'n' }, '<C-c>', cancel)
					map('n', 'q', cancel)
					return true
				end,
			})
		end
		if opts.ask_root then
			vim.ui.input({
				prompt = 'Search executable from: ', default = vim.fn.getcwd(), completion = 'dir',
			}, function(root)
				if not root or root == '' then finish(require('dap').ABORT) else open(root) end
			end)
		else
			open(vim.fn.getcwd())
		end
	end)
end

local function input(opts, convert)
	return coroutine.create(function(co)
		vim.ui.input(opts, function(value)
			if value == nil then
				value = require('dap').ABORT
			else
				value = convert(value)
			end
			vim.schedule(function()
				local ok, err = coroutine.resume(co, value)
				if not ok then vim.notify(err, vim.log.levels.ERROR) end
			end)
		end)
	end)
end

function M.arguments()
	return input({ prompt = 'Args: ' }, require('dap.utils').splitstr)
end

function M.server_address()
	return input({ prompt = '[host]:port: ', default = 'localhost:1234' }, function(uri)
		if uri == '' then return require('dap').ABORT end
		if uri:match('^%d+$') then return 'localhost:' .. uri end
		if uri:sub(1, 1) == ':' then return 'localhost' .. uri end
		return uri
	end)
end

function M.action(callback, use_cursor)
	return function(...) return require('dap-extra.ui').action(callback, use_cursor)(...) end
end

function M.setup(opts)
	local dap = require 'dap'

	require('mason-nvim-dap').setup(opts)

	-- Adapter setups and configs:
	dap.adapters.cppdbg = dap.adapters.cppdbg or {
		id = 'cppdbg',
		type = 'executable',
		command = vim.fn.exepath('OpenDebugAD7') ~= '' and vim.fn.exepath('OpenDebugAD7') or 'OpenDebugAD7',
	}

	dap.adapters.ocamlearlybird = {
		type = 'executable',
		command = 'ocamlearlybird',
		args = { 'debug' }
	}
	dap.configurations.ocaml = {
		{
			name = 'OCaml Debug',
			type = 'ocamlearlybird',
			request = 'launch',
			program = function() return M.select_executable({ bytecode = true }) end,
		},
		{
			name = 'OCaml Debug with find path',
			type = 'ocamlearlybird',
			request = 'launch',
			program = function() return M.select_executable({ bytecode = true, ask_root = true }) end,
		},
	}

	local cpp_configurations = {
		{
			name = 'Launch executable (CodeLLDB)',
			type = 'codelldb',
			request = 'launch',
			program = M.select_executable,
			cwd = '${workspaceFolder}',
			stopOnEntry = false,
			args = M.arguments,
		},
		{
			name = 'Attach process (CodeLLDB)',
			type = 'codelldb',
			request = 'attach',
			pid = require('dap.utils').pick_process,
			cwd = '${workspaceFolder}',
		},
		{
			name = 'Launch executable (GDB)',
			type = 'cppdbg',
			request = 'launch',
			program = M.select_executable,
			cwd = '${workspaceFolder}',
			args = M.arguments,
			stopAtEntry = false,
			MIMode = 'gdb',
			miDebuggerPath = vim.fn.exepath('gdb') ~= '' and vim.fn.exepath('gdb') or 'gdb',
			externalConsole = false,
			setupCommands = {
				{
					description = 'Enable GDB pretty printing',
					text = '-enable-pretty-printing',
					ignoreFailures = true,
				},
			},
		},
		{
			name = 'Attach gdbserver (GDB)',
			type = 'cppdbg',
			request = 'launch',
			MIMode = 'gdb',
			miDebuggerPath = vim.fn.exepath('gdb') ~= '' and vim.fn.exepath('gdb') or 'gdb',
			miDebuggerServerAddress = M.server_address,
			program = M.select_executable,
			cwd = '${workspaceFolder}',
		},
	}

	dap.configurations.c = cpp_configurations
	dap.configurations.cpp = cpp_configurations
	dap.configurations.rust = cpp_configurations
	require('telescope').load_extension('dap')
end

return M
