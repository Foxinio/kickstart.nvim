return {
	"whonore/Coqtail",

	dependencies = {
		'nvim-telescope/telescope.nvim'
	},

	init = function()
		vim.keymap.set('n', '<M-down>', '<Plug>CoqNext', { noremap = true })
		vim.keymap.set('n', '<M-up>', '<Plug>CoqUndo', { noremap = true })

		vim.api.nvim_create_autocmd('FileType', {
			pattern = { 'coq', 'coq-infos', 'coq-goals' },
			callback = function()
				vim.opt_local.spell = false
			end
		})
	end
}
