local M = {}
local pending = false
local changing = 0
local initialized = false
local active = false
local session = 0
local expected

-- Blink schedules its public selection operations; guard their text changes too.
local function change(fn)
	local current = session
	vim.schedule(function()
		if current ~= session then return end
		changing = changing + 1
		fn()
		vim.schedule(function()
			if current == session then
				expected = vim.fn.getcmdline()
				changing = changing - 1
			end
		end)
	end)
end

local function reset()
	pending = false
end

local function initialize()
	if initialized then return end
	initialized = true
	local group = vim.api.nvim_create_augroup('BlinkCmdlineVariants', { clear = true })
	vim.api.nvim_create_autocmd({ 'CmdlineEnter', 'CmdlineLeave' }, { group = group, callback = function()
		reset()
		session = session + 1
		active, changing = false, 0
		expected = nil
	end })
	vim.api.nvim_create_autocmd('CmdlineChanged', {
		group = group,
		callback = function()
			if changing > 0 or not active then return end
			if vim.fn.getcmdline() == expected then return end
			reset()
			local cmp = package.loaded['blink.cmp']
			if not cmp then return end
			local text, pos = vim.fn.getcmdline(), vim.fn.getcmdpos()
			local current = session
			-- Commit the edited preview as ordinary text before requesting new matches.
			change(function()
				local function refresh()
					if current ~= session then return end
					vim.fn.setcmdline(text)
					vim.fn.setcmdpos(pos)
					cmp.show()
				end
				if not cmp.hide({ callback = refresh }) then refresh() end
			end)
		end,
	})
end

function M.config(opts)
	initialize()
	local function arrow(direction)
		return function(cmp)
			if opts.arrows == false then
				reset()
				active = false
				cmp.hide()
				return
			end
			if not cmp.is_menu_visible() then reset(); return end
			pending = opts.repeat_selection
			change(function()
				cmp[direction == 1 and 'select_next' or 'select_prev']({ auto_insert = opts.insert })
			end)
			return true
		end
	end
	return {
		keymap = {
			preset = 'none',
			['<Tab>'] = { function(cmp)
				if not cmp.is_menu_visible() then
					reset()
					if opts.ghost then
						local current = session
						return cmp.show_and_insert({ callback = function()
							vim.schedule(function()
								if current ~= session then return end
								active, expected = true, vim.fn.getcmdline()
							end)
						end })
					end
					active = true
					return cmp.show()
				end
				local fill = pending and cmp.get_selected_item_idx() ~= nil
				reset()
				change(function()
					-- Back then forward fills the same item, including at either boundary.
					if fill then cmp.select_prev({ auto_insert = false }) end
					cmp.select_next({ auto_insert = true })
				end)
				return true
			end },
			['<S-Tab>'] = { function(cmp)
				reset()
				if not cmp.is_menu_visible() then return end
				change(function() cmp.select_prev({ auto_insert = true }) end)
				return true
			end, 'fallback' },
			['<Up>'] = { arrow(-1), 'fallback' },
			['<Down>'] = { arrow(1), 'fallback' },
			['<CR>'] = { function(cmp)
				reset()
				active = false
				if not cmp.is_menu_visible() or not cmp.get_selected_item() then return end
				return cmp.accept({ callback = function()
					-- Remap once through Blink's fallback so Cash receives the final search.
					vim.api.nvim_feedkeys(vim.keycode('<CR>'), 'm', false)
				end })
			end, 'fallback' },
			['<C-space>'] = { function(cmp) active = true; return cmp.show() end, 'fallback' },
			['<C-e>'] = { function() reset(); active = false end, 'cancel', 'fallback' },
			['<Left>'] = { function(cmp) reset(); active = false; cmp.hide() end, 'fallback' },
			['<Right>'] = { function(cmp) reset(); active = false; cmp.hide() end, 'fallback' },
			['<PageUp>'] = { 'scroll_documentation_up', 'fallback' },
			['<PageDown>'] = { 'scroll_documentation_down', 'fallback' },
		},
		completion = {
			menu = { auto_show = false },
			ghost_text = { enabled = opts.ghost or false },
			list = { selection = {
				preselect = opts.ghost and function()
					local cmp = require('blink.cmp')
					return not cmp.is_menu_visible() and #cmp.get_items() > 0
				end or false,
				auto_insert = opts.ghost or false,
			} },
		},
	}
end

return M
