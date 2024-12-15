local yanked_buffer = -1
local function yank()
	yanked_buffer = vim.api.nvim_get_current_buf()

	vim.api.nvim_echo({ { "Yanked buffer: " .. vim.api.nvim_buf_get_name(yanked_buffer) } }, true, {})
end

local function yank_and_close()
	yanked_buffer = vim.api.nvim_get_current_buf()

	vim.api.nvim_win_close(0, false)
end

local function paste(dir)
	if yanked_buffer == -1 then
		vim.api.nvim_echo({ { "No yanked buffer" } }, false, {})
	end

	if vim.cmd("call bufexists(" .. yanked_buffer .. ")") == 0 then
		vim.api.nvim_echo({ { "Yanked buffer doesn't exist anymore" } }, false, {})
	end

	local function open_split(direction, buffer)
		vim.cmd(direction .. " sbuffer " .. buffer)
	end

	if dir == 'left' then
		open_split('leftabove vert', yanked_buffer)
	elseif dir == 'down' then
		open_split('rightbelow', yanked_buffer)
	elseif dir == 'up' then
		open_split('leftabove', yanked_buffer)
	elseif dir == 'right' then
		open_split('rightbelow vert', yanked_buffer)
	elseif dir == 'tab-after' then
		open_split('tab', yanked_buffer)
	elseif dir == 'tab-before' then
		open_split('-tab', yanked_buffer)
	elseif dir == 'inplace' then
		vim.cmd("buffer " .. yanked_buffer)
	end
end


require('which-key').add {
	{ "<c-w>y", desc = "[Y]ank window" },
}
vim.keymap.set('n', '<c-w>yy', yank, { desc = "Yank window" })
vim.keymap.set('n', '<c-w>yq', yank_and_close, { desc = "Yank window and quit" })
vim.keymap.set('n', '<c-w>yp', function() paste('inplace') end, { desc = "Paste window" })
vim.keymap.set('n', '<c-w>y<up>', function() paste('up') end, { desc = "Paste window above" })
vim.keymap.set('n', '<c-w>y<down>', function() paste('down') end, { desc = "Paste window below" })
vim.keymap.set('n', '<c-w>y<left>', function() paste('left') end, { desc = "Paste window to the left" })
vim.keymap.set('n', '<c-w>y<right>', function() paste('right') end, { desc = "Paste window to the right" })
vim.keymap.set('n', '<c-w>yt', function() paste('tab-after') end, { desc = "Paste window in next tab" })
vim.keymap.set('n', '<c-w>yT', function() paste('tab-before') end, { desc = "Paste window in previous tab" })
