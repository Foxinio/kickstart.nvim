--  Move up/down editor lines
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

--  Enter to insert new line below with staying in normal mode
--  nmap <CR> o<ESC>

-- delete text with 'x' without changing the internal register
vim.keymap.set({ 'n', 'x' }, 'x', '"_x')



-- Terminal exit
vim.keymap.set('t', '<Esc', '<C-\\><C-n>')

--  Indent managment
vim.keymap.set('n', '<TAB>', 'i<C-t><ESC>')
vim.keymap.set('n', '<S-TAB>', 'i<C-d><ESC>')
vim.keymap.set('v', '<TAB>', '>gv')
vim.keymap.set('v', '<S-TAB>', '<gv')

--  Text scrolling
vim.keymap.set('n', '<S-Up>', '<C-y>')
vim.keymap.set('n', '<S-Down>', '<C-e>')
vim.keymap.set('n', '<S-Right>', '3zl')
vim.keymap.set('n', '<S-Left>', '3zh')
vim.keymap.set('n', '<S-ScrollWheelUp>', '3zh')
vim.keymap.set('n', '<S-ScrollWheelDown>', '3zl')

--  Make S-Y act same as S-D and S-C
vim.keymap.set('n', '<S-Y>', 'v$hy')

--  Searching
vim.keymap.set('v', '<silent>/', 'y/\\<<C-R>"\\><CR>', { silent = true })
vim.keymap.set('n', '<ESC>', ':let @/=""<cr>', { desc = "clear search", silent = true })

--  Remap help key.
vim.keymap.set('i', '<F1>', '<ESC>:set invfullscreen<CR>a')
vim.keymap.set('n', '<F1>', ':set invfullscreen<CR>')
vim.keymap.set('v', '<F1>', ':set invfullscreen<CR>')

--  Textmate holdouts

--  Formatting
vim.keymap.set('', '<leader>q', 'gqip')

--  Visualize tabs and newlines
-- vim.o.listchars = { eol = '¬', tab =  '▸' }
--  Uncomment this to enable by default:
vim.o.list = true
--  Or use your leader key + l to toggle on/off
vim.keymap.set('', '<leader>l', ':set list!<CR>', { desc = "Toggle tabs and EOL" })


vim.api.nvim_create_user_command("Sdiff", "w !diff % -", {})
vim.api.nvim_create_user_command("Vterm", function (opts)
    vim.cmd(":vert term " .. opts)
end, { nargs = 1 })
vim.api.nvim_create_user_command("Source", "source " .. vim.fn.stdpath("config"), {})
--[[ vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting(), {}) ]]
-- command! -nargs=* Vterm :vert term <args>
--     command! Source :source ~/.vimrc


-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


-- Comment bindings
-- local comment_api = require("Comment.api")
vim.keymap.set('n', "<C-/>", function()
  return vim.v.count == 0
      and '<Plug>(comment_toggle_linewise_current)'
      or '<Plug>(comment_toggle_linewise_count)'
end, { expr = true, silent = true })

vim.keymap.set('x', "<C-/>", '<Plug>(comment_toggle_linewise_visual)',
  { silent = true })

-- Toggle current line (linewise) using C-/
-- vim.keymap.set('n', '<C-_>', comment_api.toggle.linewise.current)

-- Toggle current line (blockwise) using C-\
-- vim.keymap.set('n', '<C-\\>', comment_api.toggle.blockwise.current)


-- Toggle selection (linewise)
-- vim.keymap.set('x', '<C-_>', function()
-- vim.comment_api.nvim_feedkeys(esc, 'nx', false)
-- comment_api.toggle.linewise(vim.fn.visualmode())
-- end)

-- Toggle selection (blockwise)
-- vim.keymap.set('x', '<C-\\>', function()
-- vim.comment_api.nvim_feedkeys(esc, 'nx', false)
-- comment_api.toggle.blockwise(vim.fn.visualmode())
-- end)

