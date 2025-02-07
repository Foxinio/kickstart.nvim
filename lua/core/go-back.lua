local stack = {
	root = {
		prev = nil
	}
}

local function pop_stack()
	if stack.root.prev then
		local ret = stack.root.value
		stack.root = stack.root.prev
		return ret
	else
		return nil
	end
end

local function push_stack(v)
	stack.root = {
		prev = stack.root,
		value = v,
	}
end

-- local function check_top()
-- 	return stack.root.value
-- end

local function go_back()
	local prev_buffer = pop_stack()
	if prev_buffer then
		if vim.cmd("call bufexists(" .. prev_buffer .. ")") == 0 then
			vim.api.nvim_echo({ { "Yanked buffer doesn't exist anymore" } }, false, {})
		end

		vim.cmd("buffer " .. prev_buffer)
	else
		vim.api.nvim_echo({ { "No stored buffers to go back to." } }, false, {})
	end
end

local function register_visited()
	local yanked_buffer = vim.api.nvim_get_current_buf()
	vim.api.nvim_echo({ { "Stored buffer: " .. yanked_buffer } }, false, {})

	-- if yanked_buffer ~= check_top() then
	push_stack(yanked_buffer)
	-- end
end

vim.keymap.set("n", "<leader>gb", go_back,
	{ desc = "[G]o [B]ack to previously visited buffer" })

vim.keymap.set('n', '<leader>gs', register_visited,
	{ desc = "Save current buffer to the stack" })


return {
	stack,
	go_back,
	register_visited,
}
