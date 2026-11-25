local M = {}

function M.run()
	local root = require('lazy.core.config').options.root
	local config = vim.fn.stdpath('config')
	for _, variant in ipairs({ 'highlight_advance', 'highlight_repeat', 'insert_advance', 'insert_repeat', 'tabs_only' }) do
		local channel = vim.fn.jobstart({ vim.v.progpath, '--embed', '--headless', '-u', 'NONE', '-i', 'NONE' }, { rpc = true })
		assert(channel > 0, 'could not start completion check')
		local function lua(code, args)
			return vim.rpcrequest(channel, 'nvim_exec_lua', code, args or {})
		end
		local function keys(input)
			vim.rpcrequest(channel, 'nvim_input', input)
			vim.wait(100)
		end
		local function state()
			return lua([[local cmp = require('blink.cmp')
				local items = {}
				for _, item in ipairs(cmp.get_items()) do items[#items + 1] = item.label end
				return { text = vim.fn.getcmdline(), pos = vim.fn.getcmdpos(),
					visible = cmp.is_menu_visible(), selected = cmp.get_selected_item_idx() or 0,
					items = items, submitted = vim.g.submitted or {}, mode = vim.fn.mode() }]])
		end
		local function expect(text, selected)
			local s = state()
			assert(s.text == text, variant .. ': expected ' .. vim.inspect(text) .. ', got ' .. vim.inspect(s))
			if selected ~= nil then assert(s.selected == selected, variant .. ': unexpected selection ' .. vim.inspect(s)) end
			return s
		end
		local function open()
			keys('<C-c>')
			keys(':InputCheck al')
			expect('InputCheck al', 0)
			keys('<Tab>')
			local s = expect('InputCheck al', 0)
			assert(s.visible and #s.items == 3, variant .. ': menu did not open ' .. vim.inspect(s))
			return s.items
		end
		local ok, err = xpcall(function()
			lua([[
				local root, config, variant = ...
				vim.opt.rtp:prepend(root .. '/blink.cmp')
				vim.opt.rtp:prepend(root .. '/cash.nvim')
				vim.opt.rtp:prepend(config)
				require('cash').setup({ mapKeys = { questionMark = false, functionKeys = false } })
				vim.api.nvim_create_user_command('InputCheck', function(opts)
					local values = vim.g.submitted or {}
					values[#values + 1] = opts.args
					vim.g.submitted = values
				end, { nargs = '*', complete = function()
					return vim.g.matches or { 'alpha', 'alpine', 'algebra' }
				end })
				local opts = { insert = variant:match('^insert') ~= nil,
					repeat_selection = variant:match('repeat$') ~= nil }
				if variant == 'tabs_only' then opts.arrows = false end
				require('blink.cmp').setup({ fuzzy = { implementation = 'lua' },
					sources = { default = { 'buffer' } },
					completion = { list = { selection = { preselect = true, auto_insert = false } } },
					cmdline = require('plugin-utils.blink-cmdline').config(opts) })
			]], { root, config, variant })
			local items = open()
			keys('<Tab>')
			expect('InputCheck ' .. items[1], 1)
			keys('<Tab><Tab>')
			expect('InputCheck ' .. items[3], 3)
			keys('<Tab>')
			expect('InputCheck al', 0)
			keys('<S-Tab>')
			expect('InputCheck ' .. items[3], 3)
			keys('<S-Tab><S-Tab><S-Tab>')
			expect('InputCheck al', 0)
			if variant == 'tabs_only' then
				lua([[vim.fn.histadd(':', 'InputCheck alhistory')]])
				keys('<Up>')
				assert(not expect('InputCheck alhistory').visible, 'history reopened completion')
				keys('<Down>')
				expect('InputCheck al')
			else
				items = open()
				keys('<Down>')
				local insert = variant:match('^insert') ~= nil
				expect(insert and 'InputCheck ' .. items[1] or 'InputCheck al', 1)
				keys('<Tab>')
				local index = variant:match('repeat$') and 1 or 2
				expect('InputCheck ' .. items[index], index)
				keys('<Tab>')
				expect('InputCheck ' .. items[index + 1], index + 1)
				items = open()
				keys('<Up>')
				keys('<Tab>')
				if variant:match('repeat$') then
					expect('InputCheck ' .. items[3], 3)
				else
					expect('InputCheck al', 0)
				end
			end
			items = open()
			keys('<Tab>')
			keys('p')
			local edited = 'InputCheck ' .. items[1] .. 'p'
			expect(edited, 0)
			keys('<BS>')
			assert(expect('InputCheck ' .. items[1], 0).visible, 'backspace did not restore matches')
			keys('<Tab>')
			keys('<Tab>')
			expect('InputCheck ' .. items[1], 0)
			keys('<Left>')
			local s = expect('InputCheck ' .. items[1])
			assert(not s.visible and s.pos == #s.text, 'Left did not hide and move within filled text')
			open()
			keys('<Tab>')
			keys('<C-e>')
			assert(not expect('InputCheck al', 0).visible, 'cancel left the menu open')
			keys('<C-c>')
			keys(':InputCheck ag')
			keys('<Tab>')
			s = expect('InputCheck ag', 0)
			assert(vim.tbl_contains(s.items, 'algebra'), 'non-prefix fuzzy match missing')
			lua([[vim.g.matches = { 'alpha' }]])
			keys('<C-c>')
			keys(':InputCheck al')
			keys('<Tab>')
			expect('InputCheck al', 0)
			keys('<Tab>')
			expect('InputCheck alpha', 1)
			keys('<Tab>')
			expect('InputCheck al', 0)
			keys('<S-Tab>')
			expect('InputCheck alpha', 1)
			lua([[vim.g.matches = {}]])
			keys('<C-c>')
			keys(':InputCheck zzz')
			keys('<Tab>')
			assert(not expect('InputCheck zzz', 0).visible, 'empty menu visible')
			assert(#state().submitted == 0, 'no matches submitted input')
			lua([[vim.g.matches = nil]])
			open()
			keys('<CR>')
			assert(vim.deep_equal(state().submitted, { 'al' }), 'Enter without selection did not submit once')
			items = open()
			keys('<Tab>')
			keys('<CR>')
			assert(vim.deep_equal(state().submitted, { 'al', items[1] }), 'Enter with selection did not submit once')
			-- An actual completed search must pass through Cash's Enter mapping.
			lua([[vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'alpha alpine algebra' })]])
			keys('/alp')
			keys('<Tab>')
			keys('<Down>')
			keys('<CR>')
			lua([[local state = require('cash').state
				assert(state.cashRegisters[state.currentIndex].pattern == vim.fn.getreg('/'), 'Cash missed completed search')]])
			-- The command-line variant must not change file-buffer completion settings.
			keys('oal')
			lua([[require('blink.cmp').show()]])
			vim.wait(100)
			lua([[local cmp = require('blink.cmp')
				assert(cmp.is_menu_visible() and cmp.get_selected_item_idx() == 1, 'file-buffer preselection changed')]])
		end, debug.traceback)
		vim.fn.jobstop(channel)
		assert(ok, variant .. ': ' .. tostring(err))
	end
end

return M
