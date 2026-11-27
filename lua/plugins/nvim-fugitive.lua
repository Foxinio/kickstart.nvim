local M = { "Foxinio/nvim-fugitive" }
M.branch = "main"
M.lazy = false
M.main = "nvim-fugitive"

M.dependencies = { "nvim-lua/plenary.nvim" }

M.keys = {
	{ "<leader>hh", "<cmd>Git<CR>", desc = "Git summary" },
}

M.opts = {
	args = { commit = { "--signoff" } },
}

return M
