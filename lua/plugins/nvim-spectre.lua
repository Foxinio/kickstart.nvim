local M = {
  "nvim-pack/nvim-spectre",
}

M.keys = {
	{'<F4>', "<cmd>SpectreWithCWD<cr>",mode={'n'}},
}

M.opts = {
	is_block_ui_break = true,
}

return M
