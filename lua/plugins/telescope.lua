-- Fuzzy Finder (files, lsp, etc)
local M = {
	'nvim-telescope/telescope.nvim',
	version = '*',
}
M.dependencies = {
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
}

M.opts = {
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

M.config = function()
	local telescope = require('telescope')
	local telescope_utils = require('utils.telescope')

	telescope.setup(M.opts)
	-- Enable telescope fzf native, if installed
	telescope.load_extension('fzf')
	telescope.load_extension('ui-select')
	telescope.load_extension('live_grep_args')


-- ###########################################################################
-- User command declarations

-- ###########################################################################
-- Keymap bindings declarations

	-- See `:help telescope.builtin`
	vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
	vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
	vim.keymap.set('n', '<leader>/', telescope_utils.current_buffer_fuzzy_find,
		{ desc = '[/] Fuzzily search in current buffer' })

	vim.keymap.set('n', '<leader>s/', telescope_utils.live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
	vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
	vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
	vim.keymap.set('n', '<leader>sf', function()
		telescope_utils.find_files_with_editable_root({
			prompt_title = 'Find Files',
		})
	end, { desc = '[S]earch [F]iles' })
	vim.keymap.set('n', '<leader>sF', function()
		telescope_utils.find_files_with_editable_root({
			prompt_title = 'Find Files (All)',
			find_files_opts = {
				hidden = true,
				no_ignore = true,
			},
		})
	end, { desc = '[S]earch All [F]iles' })
	vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
	vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
	vim.keymap.set('n', '<leader>sg', telescope_utils.live_grep_with_editable_args, { desc = '[S]earch with editable rg flags' })
	vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
	vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
	vim.keymap.set('n', '<leader>sj', require('telescope.builtin').jumplist, { desc = "[S]how [J]ump list" })
end

return M
