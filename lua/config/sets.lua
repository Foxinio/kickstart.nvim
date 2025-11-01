-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set spellcheck on
vim.o.spellsuggest  = 'best'
vim.o.spell         = true
vim.o.spelllang     = 'en_us,pl'

-- Set highlight on search
vim.o.hlsearch      = true
vim.o.incsearch     = true
vim.o.magic         = true
vim.o.showmatch     = true

-- Make line numbers default
vim.wo.number       = true

-- Use visual bell instead of beeping,
vim.o.visualbell    = true

-- Whitespaces
vim.o.wrap          = false
vim.o.sidescroll    = 2
vim.o.formatoptions = 'tcqrn1'

-- expand tab
vim.opt.expandtab   = true
vim.o.shiftwidth    = 2
vim.o.tabstop       = 2
vim.o.softtabstop   = 2
vim.o.shiftround    = false
vim.o.smartindent   = true

-- Cursor motion
vim.o.scrolloff     = 3
vim.o.sidescrolloff = 3


-- highlight 80 character column
vim.o.colorcolumn    = "80"

-- Enable mouse mode
vim.o.mouse          = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
--vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent    = true

-- Save undo history
vim.o.undofile       = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase     = true
vim.o.smartcase      = true

-- Keep signcolumn on by default
vim.wo.signcolumn    = 'yes'

-- Decrease update time
vim.o.updatetime     = 2000
vim.o.timeoutlen     = 300

-- Last line
vim.o.showmode       = true
vim.o.showcmd        = true
vim.o.wildmenu       = true
vim.o.wildmode       = 'full'
vim.o.wildignorecase = true

-- Set completeopt to have a better completion experience
vim.o.completeopt    = 'menu,menuone,noselect,noinsert,preview'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors  = true

-- Since im using a separate completion engine, builtin one is disabled
-- require('cmp').setup({ enabled = false })

-- in case default is ever changed
vim.o.backspace = 'indent,eol,start'

-- vim.opt.swapfile = false

vim.o.indentkeys = ""

vim.o.cinwords = ""
vim.o.cink = ""
vim.o.indk = ""

vim.o.list = true

-- vim.g.python_host_prog = '/usr/bin/python'
-- vim.g.python3_host_prog = '/home/foxinio/.local/share/nvim/pyvenv/bin/python'


-- Automatically setup folds
-- vim.o.foldmethod = "expr"
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
-- Currently handled by nvim-origami

-- vim.api.nvim_call_function("codeium#GetStatusString", {})

-- adding python support
-- vim.cmd([[
--
-- let g:python_host_prog = '/usr/bin/python'
-- let g:python3_host_prog = '/usr/bin/python3'
--
-- ]])
