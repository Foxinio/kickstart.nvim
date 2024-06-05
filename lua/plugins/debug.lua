-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
	-- NOTE: Yes, you can install new plugins here!
	'mfussenegger/nvim-dap',
	-- NOTE: And you can specify dependencies as well
	dependencies = {
		-- Creates a beautiful debugger UI
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',

		-- Installs the debug adapters for you
		'williamboman/mason.nvim',
		'jay-babu/mason-nvim-dap.nvim',

		-- Add your own debuggers here
		'leoluz/nvim-dap-go',
	},
	config = function()
		local dap = require 'dap'
		local dapui = require 'dapui'

		require('mason-nvim-dap').setup {
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
			},
		}

		-- Basic debugging keymaps, feel free to change to your liking!
		vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
		vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
		vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
		vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
		vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
		vim.keymap.set('n', '<leader>dr', dap.list_breakpoints, { desc = 'Debug: List Breakpoints' })
		vim.keymap.set('n', '<leader>dl', dap.run_to_cursor, { desc = 'Debug: Run To Cursor' })
		vim.keymap.set('n', '<leader>dk', dap.up, { desc = 'Debug: Go up current stacktrace' })
		vim.keymap.set('n', '<leader>dj', dap.down, { desc = 'Debug: Go down current stacktrace' })
		vim.keymap.set('n', '<leader>B', function()
			dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
		end, { desc = 'Debug: Set Breakpoint' })


		-- Adapter setups and configs:
		dap.adapters.ocamlearlybird = {
			type = 'executable',
			command = 'ocamlearlybird',
			args = { 'debug' }
		}


		local function select_exec(path)
			path = path or vim.fn.getcwd()
			local find_res = io.popen("find "..path.." -name *.bc -executable -type f"):read("*a")
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
						prompt="Enter path to search executable from: ",
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
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
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

		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

		dap.listeners.after.event_initialized['dapui_config'] = dapui.open
		dap.listeners.before.event_terminated['dapui_config'] = dapui.close
		dap.listeners.before.event_exited['dapui_config'] = dapui.close

		-- Install golang specific config
		require('dap-go').setup()
	end,
}
