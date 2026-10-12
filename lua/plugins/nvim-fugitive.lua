local M = { "Foxinio/nvim-fugitive", }
M.branch = "main"

M.dependencies = { "nvim-lua/plenary.nvim" }


M.cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit", "Ggrep", "Glgrep",
	"GMove", "GRename", "GDelete", "GRemove", "GUnlink", "GBrowse",
	"FugitiveOutput", "FugitiveRestore" }
M.opts = {} -- optional, see :help fugitive-config

return M
