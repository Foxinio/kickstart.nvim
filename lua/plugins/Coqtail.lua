return {
	"whonore/Coqtail",

	dependencies = {
		'nvim-telescope/telescope.nvim'
	},

	-- ft = "coq",
  build = function()
    vim.cmd("!pip install --user -r requirements.txt")
  end,

	init = function()
		vim.keymap.set('n', '<M-down>', '<Plug>CoqNext', { noremap = true })
		vim.keymap.set('n', '<M-up>', '<Plug>CoqUndo', { noremap = true })

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
}
