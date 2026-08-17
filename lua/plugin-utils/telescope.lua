local M = {}

local function resolve(value, ...)
	if type(value) == 'function' then
		return value(...)
	end

	return value
end

local function default_parse_cmd_args(input)
	if input == nil or input == '' then
		return {}
	end

	return vim.split(input, '%s+', { trimempty = true })
end

function M.append_all(target, source)
	for _, value in ipairs(source or {}) do
		table.insert(target, value)
	end
end

function M.root_label(cwd)
	local label = vim.fn.fnamemodify(cwd, ':~:.')
	if label == '' then
		return cwd
	end

	return label
end

function M.find_git_root()
	local current_file = vim.api.nvim_buf_get_name(0)
	local current_dir
	local cwd = vim.fn.getcwd()

	if current_file == '' then
		current_dir = cwd
	else
		current_dir = vim.fn.fnamemodify(current_file, ':h')
	end

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

function M.live_grep_git_root(opts)
	local git_root = M.find_git_root()
	if git_root then
		require('telescope.builtin').live_grep(vim.tbl_extend('force', opts or {}, {
			search_dirs = { git_root },
		}))
	end
end

function M.current_buffer_fuzzy_find(opts)
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown(vim.tbl_extend('force', {
		winblend = 10,
		previewer = false,
	}, opts or {})))
end

-- Owns common editable picker state; callers own picker-specific Telescope construction.
function M.editable_root_picker(opts)
	opts = opts or {}
	assert(type(opts.open) == 'function', 'editable_root_picker requires an open callback')

	local actions = require('telescope.actions')
	local action_state = require('telescope.actions.state')
	local parse_cmd_args = opts.parse_cmd_args or default_parse_cmd_args

	local function open_picker(default_text, state)
		state = vim.tbl_extend('force', {
			cwd = vim.fn.getcwd(),
			cmd_args = {},
		}, state or {})

		local picker_opts = vim.tbl_extend('force', opts.picker_opts or {}, {
			cwd = state.cwd,
			default_text = default_text,
		})
		local prompt_title = resolve(opts.prompt_title, state)

		if prompt_title ~= nil then
			picker_opts.prompt_title = prompt_title
		end

		local picker_attach_mappings = picker_opts.attach_mappings

		picker_opts.attach_mappings = function(prompt_bufnr, map)
			map('i', opts.cmd_args_key or '<C-a>', function()
				local picker = action_state.get_current_picker(prompt_bufnr)
				local prompt = picker:_get_prompt()
				actions.close(prompt_bufnr)

				vim.schedule(function()
					vim.ui.input({
						prompt = opts.cmd_args_prompt or 'cmd args: ',
						default = table.concat(state.cmd_args, ' '),
					}, function(input)
						if input == nil then
							open_picker(prompt, state)
							return
						end

						open_picker(prompt, vim.tbl_extend('force', {}, state, {
							cmd_args = parse_cmd_args(input, state),
						}))
					end)
				end)
			end)

			map('i', opts.root_key or '<C-s>', function()
				local picker = action_state.get_current_picker(prompt_bufnr)
				local prompt = picker:_get_prompt()
				actions.close(prompt_bufnr)

				vim.schedule(function()
					vim.ui.input({
						prompt = opts.root_prompt or 'search root: ',
						default = state.cwd,
						completion = 'dir',
					}, function(input)
						if input == nil then
							open_picker(prompt, state)
							return
						end

						local next_cwd = vim.fn.fnamemodify(input, ':p')
						if vim.fn.isdirectory(next_cwd) == 0 then
							vim.notify('Search root is not a directory: ' .. input, vim.log.levels.WARN)
							open_picker(prompt, state)
							return
						end

						open_picker(prompt, vim.tbl_extend('force', {}, state, { cwd = next_cwd }))
					end)
				end)
			end)

			if picker_attach_mappings and picker_attach_mappings(prompt_bufnr, map) == false then
				return false
			end

			if opts.attach_mappings then
				return opts.attach_mappings(prompt_bufnr, map, state)
			end

			return true
		end

		opts.open(state, picker_opts)
	end

	open_picker(opts.default_text, opts.initial_state)
end

function M.live_grep_with_editable_args()
	local conf = require('telescope.config').values
	local finders = require('telescope.finders')
	local make_entry = require('telescope.make_entry')
	local pickers = require('telescope.pickers')
	local sorters = require('telescope.sorters')
	local prompt_parser = require('telescope-live-grep-args.prompt_parser')

	local function parse_args(input)
		if input == nil or input == '' then
			return {}
		end

		return prompt_parser.parse(input, false)
	end

	M.editable_root_picker({
		cmd_args_prompt = 'rg flags: ',
		parse_cmd_args = parse_args,
		prompt_title = function(state)
			local root = M.root_label(state.cwd)
			return 'Live Grep (' .. root .. ') [' .. table.concat(state.cmd_args, ' ') .. ']'
		end,
		open = function(state, picker_opts)
			picker_opts.entry_maker = make_entry.gen_from_vimgrep(picker_opts)

			local base_args = {}
			M.append_all(base_args, conf.vimgrep_arguments)
			M.append_all(base_args, state.cmd_args)

			pickers.new(picker_opts, {
				finder = finders.new_job(function(prompt)
					if not prompt or prompt == '' then
						return nil
					end

					local command = {}
					M.append_all(command, base_args)
					table.insert(command, '--')
					table.insert(command, prompt)
					return command
				end, picker_opts.entry_maker, picker_opts.max_results, picker_opts.cwd),
				previewer = conf.grep_previewer(picker_opts),
				sorter = sorters.highlighter_only(picker_opts),
				attach_mappings = picker_opts.attach_mappings,
			}):find()
		end,
	})
end

function M.find_files_with_editable_root(opts)
	opts = opts or {}

	M.editable_root_picker({
		picker_opts = opts.find_files_opts,
		prompt_title = opts.prompt_title or function(state)
			return 'Find Files (' .. M.root_label(state.cwd) .. ')'
		end,
		open = function(_, picker_opts)
			require('telescope.builtin').find_files(picker_opts)
		end,
	})
end

function M.live_grep_open_files(opts)
	require('telescope.builtin').live_grep(vim.tbl_extend('force', {
		grep_open_files = true,
		prompt_title = 'Live Grep in Open Files',
	}, opts or {}))
end

function M.find_file_in_nvim_tree(opts)
	opts = opts or {}

	local picker_attach_mappings = opts.attach_mappings
	local picker_opts = vim.tbl_extend('force', {
		winblend = 10,
		previewer = false,
		prompt_title = 'Select File',
		cwd = require('nvim-tree.core').get_cwd(),
	}, opts)
	picker_opts.attach_mappings = function(prompt_bufnr, map)
		local function select_file()
			require('telescope.actions').close(prompt_bufnr)

			local entry = require('telescope.actions.state').get_selected_entry()
			local path = entry and (entry.path or entry[1])
			if not path or path == '' then
				return
			end

			require('nvim-tree.api').tree.find_file({
				open = true,
				focus = true,
				buf = path,
			})
		end

		map('i', '<CR>', select_file)
		map('n', '<CR>', select_file)

		if picker_attach_mappings then
			return picker_attach_mappings(prompt_bufnr, map)
		end

		return true
	end

	require('telescope.builtin').find_files(require('telescope.themes').get_dropdown(picker_opts))
end

return M
