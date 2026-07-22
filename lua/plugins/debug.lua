-- debug.lua

local M = {
	-- NOTE: Yes, you can install new plugins here!
	'mfussenegger/nvim-dap',
}

-- NOTE: And you can specify dependencies as well
M.dependencies = {
	-- Creates a beautiful debugger UI
	'rcarriga/nvim-dap-ui',
	'nvim-neotest/nvim-nio',
	'theHamsta/nvim-dap-virtual-text',
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

M.keys = {
	{ '<F5>', continue_or_cmake_debug, desc = 'Debug: Start/Continue' },
	{ '<F10>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
	{ '<F11>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
	{ '<F12>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
	{ '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
	{ '<leader>dc', continue_or_cmake_debug, desc = 'Debug: Start/Continue' },
	{ '<leader>dC', cmake_quick_debug, desc = 'Debug: CMake Target' },
	{ '<leader>df', cmake_debug_current_file, desc = 'Debug: CMake Current File' },
	{ '<leader>dq', function() require('dap').terminate() end, desc = 'Debug: Terminate' },
	{ '<leader>dR', function() require('dap').restart() end, desc = 'Debug: Restart' },
	{ '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Debug: Toggle REPL' },
	{ '<leader>db', function() require('dap').list_breakpoints() end, desc = 'Debug: List Breakpoints' },
	{ '<leader>ds', function() require('telescope').extensions.dap.configurations() end, desc = 'Debug: Select Configuration' },
	{ '<leader>dS', function() require('telescope').extensions.dap.frames() end, desc = 'Debug: Select Stack Frame' },
	{ '<leader>dl', function() require('dap').run_to_cursor() end, desc = 'Debug: Run To Cursor' },
	{ '<leader>dk', function() require('dap').up() end, desc = 'Debug: Go up current stacktrace' },
	{ '<leader>dj', function() require('dap').down() end, desc = 'Debug: Go down current stacktrace' },
	{ '<leader>B', function()
		require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
	end, desc = 'Debug: Set Breakpoint' },
	{ '<F7>', function() require('dapui').toggle() end, desc = 'Debug: See last session result.' },
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
		local dap = require 'dap'
		local dapui = require 'dapui'

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

		require('nvim-dap-virtual-text').setup({
			enabled = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = true,
			show_stop_reason = true,
			commented = false,
			only_first_definition = true,
			all_references = false,
			clear_on_continue = false,
		})

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup {
			icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
			layouts = {
				{
					elements = {
						{ id = 'scopes', size = 0.45 },
						{ id = 'breakpoints', size = 0.15 },
						{ id = 'stacks', size = 0.25 },
						{ id = 'watches', size = 0.15 },
					},
					position = 'left',
					size = 48,
				},
				{
					elements = {
						{ id = 'repl', size = 0.5 },
						{ id = 'console', size = 0.5 },
					},
					position = 'bottom',
					size = 12,
				},
			},
			floating = {
				border = 'rounded',
			},
			controls = {
				enabled = true,
				element = 'repl',
				icons = {
					pause = '⏸',
					play = '▶',
					step_into = '⏎',
					step_over = '⏭',
					step_out = '⏮',
					step_back = 'b',
					run_last = '▶▶',
					terminate = '⏹',
					disconnect = '⏏',
				},
			},
		}

		vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
		vim.fn.sign_define('DapBreakpointCondition', { text = '🟨', texthl = '', linehl = '', numhl = '' })
		vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = '', linehl = '', numhl = '' })
		vim.fn.sign_define('DapStopped', { text = '▶', texthl = '', linehl = 'Visual', numhl = '' })
		vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })

		local ok_telescope, telescope = pcall(require, 'telescope')
		if ok_telescope then
			pcall(telescope.load_extension, 'dap')
		end

		dap.listeners.after.event_initialized['dapui_config'] = dapui.open
		dap.listeners.before.event_terminated['dapui_config'] = dapui.close
		dap.listeners.before.event_exited['dapui_config'] = dapui.close
end

return M
