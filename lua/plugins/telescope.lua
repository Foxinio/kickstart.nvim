-- Fuzzy Finder (files, lsp, etc)
return {
	'nvim-telescope/telescope.nvim',
	version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		-- Fuzzy Finder Algorithm which requires local dependencies to be built.
		-- Only load if `make` is available. Make sure you have the system
		-- requirements installed.
		{
			'nvim-telescope/telescope-fzf-native.nvim',
			-- NOTE: If you are having trouble with this installation,
			--       refer to the README for telescope-fzf-native for more instructions.
			build = 'make',
			cond = function()
				return vim.fn.executable 'make' == 1
			end,
		},
		'nvim-telescope/telescope-ui-select.nvim',
		{
				"nvim-telescope/telescope-live-grep-args.nvim" ,
				-- This will not install any breaking changes.
				-- For major updates, this must be adjusted manually.
				version = "^1.0.0",
		},
	},
	config = function()
		local telescope = require('telescope')

		telescope.setup {
			defaults = {
				layout_strategy = 'vertical',
				layout_config = { height = 0.95 },
				mappings = {
					i = {
						['<C-u>'] = false,
						['<C-d>'] = false,
					},
				},
			},
		}
		-- Enable telescope fzf native, if installed
		telescope.load_extension('fzf')
		telescope.load_extension('ui-select')
		telescope.load_extension('live_grep_args')


-- ###########################################################################
-- Local pickers, sorters, previewers definitions

		-- Telescope live_grep in git root
		-- Function to find the git root directory based on the current buffer's path
		local function find_git_root()
			-- Use the current buffer's path as the starting point for the git search
			local current_file = vim.api.nvim_buf_get_name(0)
			local current_dir
			local cwd = vim.fn.getcwd()
			-- If the buffer is not associated with a file, return nil
			if current_file == '' then
				current_dir = cwd
			else
				-- Extract the directory from the current file's path
				current_dir = vim.fn.fnamemodify(current_file, ':h')
			end

			-- Find the Git root directory from the current file's path
			local git_root =
					vim.fn.systemlist('git -C '
						.. vim.fn.escape(current_dir, ' ')
						.. ' rev-parse --show-toplevel')[1]
			if vim.v.shell_error ~= 0 then
				print 'Not a git repository. Searching on current working directory'
				return cwd
			end
			return git_root
		end

		-- Custom live_grep function to search in git root
		local function live_grep_git_root()
			local git_root = find_git_root()
			if git_root then
				require('telescope.builtin').live_grep {
					search_dirs = { git_root },
				}
			end
		end

		local function live_grep_with_editable_args()
			local actions = require('telescope.actions')
			local action_state = require('telescope.actions.state')
			local conf = require('telescope.config').values
			local finders = require('telescope.finders')
			local make_entry = require('telescope.make_entry')
			local pickers = require('telescope.pickers')
			local sorters = require('telescope.sorters')
			local prompt_parser = require('telescope-live-grep-args.prompt_parser')

			local function append_all(target, source)
				for _, value in ipairs(source or {}) do
					table.insert(target, value)
				end
			end

			local function parse_args(input)
				if input == nil or input == '' then
					return {}
				end

				return prompt_parser.parse(input, false)
			end

			local function open_picker(default_text, rg_args, cwd)
				rg_args = rg_args or {}
				cwd = cwd or vim.fn.getcwd()

				local root_label = vim.fn.fnamemodify(cwd, ':~:.')
				if root_label == '' then
					root_label = cwd
				end

				local opts = {
					cwd = cwd,
					default_text = default_text,
					entry_maker = make_entry.gen_from_vimgrep {},
					prompt_title = #rg_args == 0
							and 'Live Grep (' .. root_label .. ')'
							or 'Live Grep (' .. root_label .. ', rg ' .. table.concat(rg_args, ' ') .. ')',
				}
				local base_args = {}
				append_all(base_args, conf.vimgrep_arguments)
				append_all(base_args, rg_args)

				pickers.new(opts, {
					finder = finders.new_job(function(prompt)
						if not prompt or prompt == '' then
							return nil
						end

						local command = {}
						append_all(command, base_args)
						table.insert(command, '--')
						table.insert(command, prompt)
						return command
					end, opts.entry_maker, opts.max_results, opts.cwd),
					previewer = conf.grep_previewer(opts),
					sorter = sorters.highlighter_only(opts),
					attach_mappings = function(prompt_bufnr, map)
						map('i', '<C-f>', function()
							local picker = action_state.get_current_picker(prompt_bufnr)
							local prompt = picker:_get_prompt()
							actions.close(prompt_bufnr)

							vim.schedule(function()
								vim.ui.input({
									prompt = 'rg flags: ',
									default = table.concat(rg_args, ' '),
								}, function(input)
									if input == nil then
										open_picker(prompt, rg_args, cwd)
										return
									end

									open_picker(prompt, parse_args(input), cwd)
								end)
							end)
						end)

						map('i', '<C-r>', function()
							local picker = action_state.get_current_picker(prompt_bufnr)
							local prompt = picker:_get_prompt()
							actions.close(prompt_bufnr)

							vim.schedule(function()
								vim.ui.input({
									prompt = 'search root: ',
									default = cwd,
									completion = 'dir',
								}, function(input)
									if input == nil then
										open_picker(prompt, rg_args, cwd)
										return
									end

									local next_cwd = vim.fn.fnamemodify(input, ':p')
									if vim.fn.isdirectory(next_cwd) == 0 then
										vim.notify('Search root is not a directory: ' .. input, vim.log.levels.WARN)
										open_picker(prompt, rg_args, cwd)
										return
									end

									open_picker(prompt, rg_args, next_cwd)
								end)
							end)
						end)

						return true
					end,
				}):find()
			end

			open_picker()
		end

-- ###########################################################################
-- User command declarations

		vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- ###########################################################################
-- Keymap bindings declarations

		-- See `:help telescope.builtin`
		vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
		vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
		vim.keymap.set('n', '<leader>/', function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
				winblend = 10,
				previewer = false,
			})
		end, { desc = '[/] Fuzzily search in current buffer' })

		local function telescope_live_grep_open_files()
			require('telescope.builtin').live_grep {
				grep_open_files = true,
				prompt_title = 'Live Grep in Open Files',
			}
		end


		vim.keymap.set('n', '<leader>sq', require('telescope.builtin').quickfix, { desc = '[S]earch [/] in Open Files' })
		vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
		vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
		vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
		vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
		vim.keymap.set('n', '<leader>sF', function()
			require('telescope.builtin').find_files {
				hidden = true,
				no_ignore = true,
			}
		end, { desc = '[S]earch All [F]iles' })
		vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
		vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
		vim.keymap.set('n', '<leader>sg', live_grep_with_editable_args, { desc = '[S]earch with editable rg flags' })
		-- vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
		vim.keymap.set('n', '<leader>sG', require('telescope').extensions.live_grep_args.live_grep_args,
			{ desc = '[S]earch by [G]rep with custom args' })
		vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
		vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
		vim.keymap.set('n', '<leader>sj', require('telescope.builtin').jumplist, { desc = "[S]how [J]ump list" })
	end
}
