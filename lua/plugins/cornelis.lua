local M = {
	"isovector/cornelis",
}

M.build = "stack build"

M.ft = { "agda" }

M.dependencies = {
	"kana/vim-textobj-user",
	"neovimhaskell/nvim-hs.vim",
}

M.keys = {
	{ '<leader>l', ':CornelisLoad<CR>:CornelisQuestionToMeta<CR>', ft = 'agda', silent = true },
	{ '<leader>r', ':CornelisRefine<CR>', ft = 'agda', silent = true },
	{ '<leader>d', ':CornelisMakeCase<CR>', ft = 'agda', silent = true },
	{ '<leader>,', ':CornelisTypeContext<CR>', ft = 'agda', silent = true },
	{ '<leader>.', ':CornelisTypeContextInfer<CR>', ft = 'agda', silent = true },
	{ '<leader>n', ':CornelisSolve<CR>', ft = 'agda', silent = true },
	{ '<leader>a', ':CornelisAuto<CR>', ft = 'agda', silent = true },
	{ 'gd', ':CornelisGoToDefinition<CR>', ft = 'agda', silent = true },
	{ '[/ ', ':CornelisPrevGoal<CR>', ft = 'agda', silent = true },
	{ ']/ ', ':CornelisNextGoal<CR>', ft = 'agda', silent = true },
	{ '<C-A>', ':CornelisInc<CR>', ft = 'agda', silent = true },
	{ '<C-X>', ':CornelisDec<CR>', ft = 'agda', silent = true },
	{ '<C-Space>', ':CornelisGive<CR>', ft = 'agda', silent = true },
}

M.init = function()
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "*.agda",
		callback = function()
			vim.cmd("CornelisLoad")
		end,
	})

	vim.g.cornelis_split_location = "bottom"
end

return M
