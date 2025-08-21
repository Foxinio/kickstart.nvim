return {
	"isovector/cornelis",
	ft = { "agda" },
	build = "stack build",
	dependencies = {
		"kana/vim-textobj-user",
		"neovimhaskell/nvim-hs.vim",
	},
	init = function()

		-- Define the Agda key mappings as a function
		local function agda_filetype()
			local opts = { buffer = true, noremap = true, silent = true }
			vim.keymap.set('n', '<leader>l', ':CornelisLoad<CR>:CornelisQuestionToMeta<CR>', opts)
			vim.keymap.set('n', '<leader>r', ':CornelisRefine<CR>', opts)
			vim.keymap.set('n', '<leader>d', ':CornelisMakeCase<CR>', opts)
			vim.keymap.set('n', '<leader>,', ':CornelisTypeContext<CR>', opts)
			vim.keymap.set('n', '<leader>.', ':CornelisTypeContextInfer<CR>', opts)
			vim.keymap.set('n', '<leader>n', ':CornelisSolve<CR>', opts)
			vim.keymap.set('n', '<leader>a', ':CornelisAuto<CR>', opts)
			vim.keymap.set('n', 'gd',        ':CornelisGoToDefinition<CR>', opts)
			vim.keymap.set('n', '[/ ',       ':CornelisPrevGoal<CR>', opts)
			vim.keymap.set('n', ']/ ',       ':CornelisNextGoal<CR>', opts)
			vim.keymap.set('n', '<C-A>',     ':CornelisInc<CR>', opts)
			vim.keymap.set('n', '<C-X>',     ':CornelisDec<CR>', opts)
			vim.keymap.set('n', '<C-Space>', ':CornelisGive<CR>', opts)
		end

		-- Auto command to set keymaps for Agda files
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			pattern = "*.agda",
			callback = agda_filetype,
		})

		-- Auto command to load file after write
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.agda",
			callback = function()
				vim.cmd("CornelisLoad")
			end,
		})

		vim.g.cornelis_split_location = "bottom"
	end,
}
