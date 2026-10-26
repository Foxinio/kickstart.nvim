-- debug.lua

local M = {
	-- NOTE: Yes, you can install new plugins here!
	'mfussenegger/nvim-dap',
}
M.module = false

-- NOTE: And you can specify dependencies as well
M.dependencies = {
	'nvim-telescope/telescope-dap.nvim',

	-- Installs the debug adapters for you
	'williamboman/mason.nvim',
	'jay-babu/mason-nvim-dap.nvim',

	-- Add your own debuggers here
	'civitasv/cmake-tools.nvim',
}

local function continue_or_cmake_debug()
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

local function cmake_quick_debug()
	local ok, cmake = pcall(require, "cmake-tools")
	if not ok or not cmake.is_cmake_project() or type(cmake.quick_debug) ~= "function" then
		vim.notify("CMake debug is only available inside a CMake project", vim.log.levels.WARN)
		return
	end

	cmake.quick_debug({ fargs = {} })
end

local function cmake_debug_current_file()
	local ok, cmake = pcall(require, "cmake-tools")
	if not ok or not cmake.is_cmake_project() or type(cmake.debug_current_file) ~= "function" then
		vim.notify("CMake debug current file is only available inside a CMake project", vim.log.levels.WARN)
		return
	end

	cmake.debug_current_file({ fargs = {} })
end

local function split_args(input)
	return vim.split(input or "", " +", { trimempty = true })
end

local function action(callback, use_cursor)
	return function(...) return require('dap-extra.ui').action(callback, use_cursor)(...) end
end

M.keys = {
	{ '<F5>', action(continue_or_cmake_debug), desc = 'Debug: Start/Continue' },
	{ '<F10>', action(function() require('dap').step_over() end), desc = 'Debug: Step Over' },
	{ '<F11>', action(function() require('dap').step_into() end), desc = 'Debug: Step Into' },
	{ '<F12>', action(function() require('dap').step_out() end), desc = 'Debug: Step Out' },
	{ '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
	{ '<leader>dc', action(continue_or_cmake_debug), desc = 'Debug: Start/Continue' },
	{ '<leader>dC', action(cmake_quick_debug), desc = 'Debug: CMake Target' },
	{ '<leader>df', action(cmake_debug_current_file, true), desc = 'Debug: CMake Current File' },
	{ '<leader>dq', action(function() require('dap').terminate() end), desc = 'Debug: Terminate' },
	{ '<leader>dR', action(function() require('dap').restart() end), desc = 'Debug: Restart' },
	{ '<leader>dr', function() require('dap-extra.ui').repl() end, desc = 'Debug: Toggle REPL' },
	{ '<leader>db', action(function() require('dap').list_breakpoints() end), desc = 'Debug: List Breakpoints' },
	{ '<leader>ds', action(function() require('telescope').extensions.dap.configurations() end), desc = 'Debug: Select Configuration' },
	{ '<leader>dS', action(function() require('telescope').extensions.dap.frames() end), desc = 'Debug: Select Stack Frame' },
	{ '<leader>dl', action(function() require('dap').run_to_cursor() end, true), desc = 'Debug: Run To Cursor' },
	{ '<leader>dk', action(function() require('dap').up() end), desc = 'Debug: Go up current stacktrace' },
	{ '<leader>dj', action(function() require('dap').down() end), desc = 'Debug: Go down current stacktrace' },
	{ '<leader>dK', function() require('dap.ui.widgets').hover() end, desc = 'Debug: Inspect value under cursor' },
	{ '<leader>dg', function() require('dap-extra.ui').local_frame() end, desc = 'Debug: Show current frame here' },
	{ '<leader>B', function()
		require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
	end, desc = 'Debug: Set Breakpoint' },
	{ '<F7>', function() require('dap-extra.ui').toggle() end, desc = 'Debug: See last session result.' },
}
M.opts = {
	-- Makes a best effort to setup the various debuggers with
	-- reasonable debug configurations
	automatic_setup = true,

	-- You can provide additional configuration to the handlers,
	-- see mason-nvim-dap README for more information
	handlers = {},

	-- You'll need to check that you have the required things installed
	-- online, please don't ask me how to install them :)
	ensure_installed = {
		-- Update this to ensure that you have the debuggers for the langs you want
		'codelldb',
		'cppdbg',
		'delve',
		'earlybird'
	},
}

M.config = function(_, opts)
		require('lazy').load({ plugins = { 'nvim-dap-extra.nvim' } })
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


		local function select_exec(path)
			path = path or vim.fn.getcwd()
			local find_res = io.popen("find " .. path .. " -name *.bc -executable -type f"):read("*a")
			local selection = vim.split(find_res, "\n")
			table.remove(selection, #selection)

			if #selection == 0 then
				vim.api.nvim_echo({ { "No executable found" } }, true, { title = "Warning" })
				return ""
			end

			if #selection == 1 then
				return selection[1]
			end

			local selected = nil
			vim.ui.select(selection, {
				prompt = 'Select executable',
			}, function(item) selected = item end)
			if selected == nil then
				-- display warning that no executable was selected
				vim.api.nvim_echo({ { "No executable selected" } }, true, { title = "Warning" })
				return ""
			else
				return selected
			end
		end

		dap.configurations.ocaml = {
			{
				name = 'OCaml Debug',
				type = 'ocamlearlybird',
				request = 'launch',
				program = function()
					return select_exec()
				end
			},
			{
				name = 'OCaml Debug with find path',
				type = 'ocamlearlybird',
				request = 'launch',
				program = function()
					local path = nil
					vim.ui.input({
						prompt = "Enter path to search executable from: ",
						default = vim.fn.getcwd(),
					}, function(input)
						path = input
					end)
					return select_exec(path)
				end
			},
		}

		local cpp_configurations = {
			{
				name = 'Launch executable (CodeLLDB)',
				type = 'codelldb',
				request = 'launch',
				program = function()
					return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = function()
					return split_args(vim.fn.input('Args: '))
				end,
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
				program = function()
					return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
				args = function()
					return split_args(vim.fn.input('Args: '))
				end,
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
				miDebuggerServerAddress = function()
					local uri = vim.fn.input('[host]:port: ', 'localhost:1234')
					if uri:find('^%d+$') == 1 then
						uri = 'localhost:' .. uri
					elseif uri:find(':', nil, true) == 1 then
						uri = 'localhost' .. uri
					end
					return uri
				end,
				program = function()
					return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				cwd = '${workspaceFolder}',
			},
		}

		dap.configurations.c = cpp_configurations
		dap.configurations.cpp = cpp_configurations
		dap.configurations.rust = cpp_configurations
		local ok_telescope, telescope = pcall(require, 'telescope')
		if ok_telescope then
			pcall(telescope.load_extension, 'dap')
		end
end

return M
