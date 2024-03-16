return {
  "whonore/Coqtail",

	init = function ()
		vim.keymap.set('n', '<M-down>', '<Plug>CoqNext', { noremap = true })
		vim.keymap.set('n', '<M-up>',   '<Plug>CoqUndo', { noremap = true })

	end
}

