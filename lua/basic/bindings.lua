--  Enter to insert new line below with staying in normal mode
--  nmap <CR> o<ESC>
vim.keymap.set('n', '<CR>', "o<ESC>", { desc = "Insert line below" })
vim.keymap.set('n', '<S-CR>', "O<ESC>", { desc = "Insert line above" })

-- Make <space> act as <C-w>
vim.keymap.set('n', '<space>', '<c-w>', { desc = "+window" })

-- delete text with 'x' without changing the internal register
vim.keymap.set({ 'n', 'x' }, 'x', '"_x')
vim.keymap.set({ 'n', 'x' }, 's', '"_s')

-- tabs manipulation
vim.keymap.set('n', '<c-tab>', function() vim.cmd('tabnext') end, { desc = "Next tab" })
vim.keymap.set('n', '<c-s-tab>', function() vim.cmd('tabNext') end, { desc = "Prev tab" })


-- Terminal exit
vim.keymap.set('t', '<Esc', '<C-\\><C-n>')

--  Indent managment
vim.keymap.set('n', '<TAB>', 'i<C-t><ESC>', { desc = "Indent line" })
vim.keymap.set('n', '<S-TAB>', 'i<C-d><ESC>', { desc = "Unindent line" })
vim.keymap.set('v', '<TAB>', '>gv', { desc = "Indent selection" })
vim.keymap.set('v', '<S-TAB>', '<gv', { desc = "Unindent selection" })

--  Text scrolling
vim.keymap.set('n', '<S-Up>', '3<C-y>', { desc = "Scroll up" })
vim.keymap.set('n', '<S-Down>', '3<C-e>', { desc = "Scroll down" })
vim.keymap.set('n', '<S-Right>', '3zl', { desc = "Scroll right" })
vim.keymap.set('n', '<S-Left>', '3zh', { desc = "Scroll left" })
vim.keymap.set('n', '<S-ScrollWheelUp>', '3zh', { desc = "Scroll right" })
vim.keymap.set('n', '<S-ScrollWheelDown>', '3zl', { desc = "Scroll left" })

--  Make S-Y act same as S-D and S-C
vim.keymap.set('n', '<S-Y>', 'v$hy', { desc = "Yank to end of line" })

--  Searching
vim.keymap.set('v', '/', 'y/\\<<C-R>"\\><CR>', { silent = true })
vim.keymap.set('n', '<ESC>', ':let @/=""<cr>', { desc = "Clear search", silent = true })

--  Remap help key.
vim.keymap.set('i', '<F1>', '<ESC>:set invfullscreen<CR>a')
vim.keymap.set({'n', 'v'}, '<F1>', ':set invfullscreen<CR>')


--  Uncomment this to enable by default:
vim.o.list = true
--  Or use your leader key + l to toggle on/off
vim.keymap.set('', '<leader>l', ':set list!<CR>', { desc = "Toggle tabs and EOL" })


vim.api.nvim_create_user_command("Sdiff", "w !diff % -", {})
vim.api.nvim_create_user_command("Vterm", function (opts)
    vim.cmd(":vert term " .. opts)
end, { nargs = 1 })
vim.api.nvim_create_user_command("Source", "source " .. vim.fn.stdpath("config"), {})


-- [[ Basic Keymaps ]]

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set('n', '<leader>xn', function()
		vim.api.nvim_echo({{"Current buffer: "}, { vim.fn.bufname() }}, true, {})
	end,
	{ desc = 'Print current buffer name' })


vim.keymap.set('n', '<M-Down>', '<CMD>move +1<CR>', { desc = 'Swap line with one below', silent = true })
vim.keymap.set('n', '<M-Up>',   '<CMD>move -2<CR>', { desc = 'Swap line with one above', silent = true })

