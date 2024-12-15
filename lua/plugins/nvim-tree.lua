return {
	'nvim-tree/nvim-tree.lua',
	dependencies = {
		'nvim-tree/nvim-web-devicons'
	},
	config = function()
		require("nvim-tree").setup({
			sort = {
				sorter = "name",
			},
			view = {
				width = 30,
			},
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = true,
			},
		})

		vim.api.nvim_create_autocmd("TabEnter", {
			command = "NvimTreeOpen",
		})

		vim.api.nvim_create_autocmd("TabLeave", {
			command = "NvimTreeClose",
		})

		vim.api.nvim_create_autocmd("TabNewEntered", {
			command = "NvimTreeOpen",
		})
	end,
	keys = {
		{ '<leader>tt', ":NvimTreeToggle<CR>", { silent = true } },
		{ '<leader>tf', ":NvimTreeFocus<CR>",  { silent = true } },
		{ '<leader>t/', ":NvimTreeFocus<CR>" },
	},
}
