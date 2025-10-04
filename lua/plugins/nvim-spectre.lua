local M = {
  "nvim-pack/nvim-spectre",
}

M.keys = {
	{'<F4>', "<cmd>SpectreWithCWD<cr>",mode={'n'}},
}

M.config = function()
	require('spectre').setup({ is_block_ui_break = true })
end

return M
