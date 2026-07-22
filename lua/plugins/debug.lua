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

	-- Installs the debug adapters for you
	'williamboman/mason.nvim',
	'jay-babu/mason-nvim-dap.nvim',

	-- Add your own debuggers here
	-- 'leoluz/nvim-dap-go',
}

M.keys = {
	{ '<F5>', function()
		local input = vim.fn.input("Enter path to search executable from: ", vim.fn.getcwd())
		local args = vim.split(input, " ")
		require('dap').continue({ args })
	end, desc = 'Debug: Start/Continue' },
	{ '<F10>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
	{ '<F11>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
	{ '<F12>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
	{ '<leader>b', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
	{ '<leader>dr', function() require('dap').list_breakpoints() end, desc = 'Debug: List Breakpoints' },
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
		'delve',
		'earlybird'
	},
}

M.config = function(_, opts)
		local dap = require 'dap'
		local dapui = require 'dapui'

		require('mason-nvim-dap').setup(opts)

		-- Adapter setups and configs:
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


		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup {
			icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
			controls = {
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

		dap.listeners.after.event_initialized['dapui_config'] = dapui.open
		dap.listeners.before.event_terminated['dapui_config'] = dapui.close
		dap.listeners.before.event_exited['dapui_config'] = dapui.close
end

return M
