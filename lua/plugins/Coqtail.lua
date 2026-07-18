local M = {
	"whonore/Coqtail",
}

M.dependencies = {
	'nvim-telescope/telescope.nvim',
}

-- M.ft = "coq"

M.keys = {
	{ '<M-down>', '<Plug>CoqNext', noremap = true },
	{ '<M-up>', '<Plug>CoqUndo', noremap = true },
}

M.build = function()
	vim.cmd("!pip install --user -r requirements.txt")
end

M.init = function()
	vim.g.coqtail_noindent = 1
	vim.g.coqtail_noindent_comments = 1
	vim.g.coqtail_auto_set_proof_diffs = 'on'

	vim.api.nvim_create_autocmd('FileType', {
		pattern = { 'coq', 'coq-infos', 'coq-goals' },
		callback = function()
			vim.opt_local.spell = false
			vim.api.nvim_set_hl(0, "CoqtailChecked", {
				bg = "#1c4d29",
			})
		end
	})

end

return M
