local M = {
	'nvim-tree/nvim-tree.lua',
	dependencies = {
		'nvim-tree/nvim-web-devicons'
	}
}

M.keys = {
	{ '<leader>tt', function ()
		require("nvim-tree.api").tree.toggle({
			path = "<args>", find_file = false, update_root = false, focus = true })
	end,
	desc = "Toggle nvim-tree", { silent = true } },

	{ '<leader>tf', function ()
		require("nvim-tree.api").tree.open()
	end,
	desc = "Focus nvim-tree", { silent = true } },

	{ '<leader>tr',  function ()
		require("nvim-tree.api").tree.reload()
	end,
	desc = "Refresh nvim-tree", { silent = true } },

	{ '<leader>t/', function()
		require("telescope.builtin").find_files(
			require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
				prompt_title = "Select File",
				cwd = require("nvim-tree.core").get_cwd(),
				attach_mappings = function(prompt_bufnr, map)
					local function select_file()
						require('telescope.actions').close(prompt_bufnr)

						local entry = require('telescope.actions.state').get_selected_entry()
						local path = entry and (entry.path or entry[1])
						if not path or path == "" then return end

						require("nvim-tree.api").tree.find_file({
							open = true, focus = true,
							buf = path
						})
					end
					map('i', '<CR>', select_file)
					map('n', '<CR>', select_file)
					return true
				end,
			}))
	end,
	desc = "Search for file in nvim-tree" },
}

M.opts = {
	sort = {
		sorter = "name",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
		special_files = {
			"Cargo.toml", "Makefile", "README.md", "readme.md",
			"dune", "dune-project", "LICENSE", "LICENSE.md",
			".gitignore",
		},
		hidden_display = "simple",
		indent_markers = {
			enable = true,
			inline_arrows = false
		},
		icons = {
			show = { folder_arrow = false }
		},
	},
	filters = {
		dotfiles = true,
	},
	actions = {
		change_dir = { global = true },
	},
	notify = {
		threshold = vim.log.levels.WARN,
		absolute_path = false,
	},
}

M.config = function ()
	require("nvim-tree").setup(M.opts)
end

return M
