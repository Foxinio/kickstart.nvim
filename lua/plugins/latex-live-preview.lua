local M = { "xuhdev/vim-latex-live-preview" }

M.cmd = { "LLPStartPreview" }

M.init = function()
	vim.g.livepreview_previewer = 'firefox'
	vim.g.livepreview_cursorhold_recompile = 0
end

return M
