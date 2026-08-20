-- Fuzzy Finder (files, lsp, etc)
local M = {
	'nvim-telescope/telescope.nvim',
}

M.version = '*'
M.event = 'VeryLazy'

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
		"nvim-telescope/telescope-live-grep-args.nvim",
			-- This will not install any breaking changes.
			-- For major updates, this must be adjusted manually.
		version = "^1.0.0",
	},
	"Foxinio/editable-telescope.nvim",
}

M.keys = {
	{ '<leader>sq', function() require('telescope.builtin').quickfix() end, desc = '[S]earch [Q]uickfix' },
	{ '<leader>?', function() require('telescope.builtin').oldfiles() end, desc = '[?] Find recently opened files' },
	{ '<leader><space>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
	{ '<leader>/', function() require('plugin-utils.telescope').current_buffer_fuzzy_find() end, desc = '[/] Fuzzily search in current buffer' },
	{ '<leader>s/', function() require('plugin-utils.telescope').live_grep_open_files() end, desc = '[S]earch [/] in Open Files' },
	{ '<leader>ss', function() require('telescope.builtin').builtin() end, desc = '[S]earch [S]elect Telescope' },
	{ '<leader>gf', function() require('telescope.builtin').git_files() end, desc = 'Search [G]it [F]iles' },
	{ '<leader>sf', function()
		require('plugin-utils.telescope').find_files_with_editable_root({
			prompt_title = 'Find Files',
		})
	end, desc = '[S]earch [F]iles' },
	{ '<leader>sF', function()
		require('plugin-utils.telescope').find_files_with_editable_root({
			prompt_title = 'Find Files (All)',
			find_files_opts = {
				hidden = true,
				no_ignore = true,
			},
		})
	end, desc = '[S]earch All [F]iles' },
	{ '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
	{ '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
	{ '<leader>sg', function() require('plugin-utils.telescope').live_grep_with_editable_args() end, desc = '[S]earch with editable rg flags' },
	{ '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
	{ '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]esume' },
	{ '<leader>sj', function() require('telescope.builtin').jumplist() end, desc = "[S]how [J]ump list" },
}

M.opts = {
	defaults = {
		layout_strategy = 'vertical',
		layout_config = { height = 0.95 },
		mappings = {
			i = {
				['<C-u>'] = false,
				['<C-d>'] = false,
				['<C-f>'] = require('utils.float-command').open_telescope_selection,
			},
			n = {
				['<C-f>'] = require('utils.float-command').open_telescope_selection,
			},
		},
	},
}

M.config = function(_, opts)
	local telescope = require('telescope')

	telescope.setup(opts)

	telescope.load_extension('fzf')
	telescope.load_extension('ui-select')
	telescope.load_extension('live_grep_args')
	telescope.load_extension('editable')
end

return M
