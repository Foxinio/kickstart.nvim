-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

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
vim.o.tabstop       = 2
vim.o.shiftwidth    = 2
vim.o.softtabstop   = 2

-- expand tab
vim.o.shiftround    = false
vim.o.smartindent   = true

-- Cursor motion
vim.o.scrolloff     = 3
vim.o.sidescrolloff = 3



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
vim.o.updatetime     = 250
vim.o.timeoutlen     = 300

-- Last line
vim.o.showmode       = true
vim.o.showcmd        = true
vim.o.wildmenu       = true
vim.o.wildmode       = 'full'
vim.o.wildignorecase = true

-- Set completeopt to have a better completion experience
vim.o.completeopt    = 'menu,menuone,noselect,noinsert'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors  = true


-- in case default is ever changed
vim.o.backspace = 'indent,eol,start'

-- vim.api.nvim_call_function("codeium#GetStatusString", {})

--[[

redundant set definitions, TODO walk through them and confirm reduncancy

set guifont=Monospace\ 13

" Custom command definitions
command! -nargs=* Vterm :vert term <args>
command! Source :source ~/.vimrc
-- ]]
