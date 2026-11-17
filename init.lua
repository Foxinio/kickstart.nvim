vim.g.mapleader = '\\'
vim.g.maplocalleader = ' '

vim.opt.spell = false
vim.cmd([[
  syntax on
  syntax spell toplevel
]])

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- scripts/check/run sets NVIM_PLUGIN_CHECK=1: test what is installed, never
-- install or update anything.
local plugin_check = vim.env.NVIM_PLUGIN_CHECK == '1'

require('lazy').setup("plugins", {
  install = {
    missing = not plugin_check,
    -- colorscheme = { "tokyonight" }
  },
  ui = {
    border = "rounded",
  },
  change_detection = { enabled = false },
  checker = { enabled = not plugin_check },
  debug = false,
})

require "config.keymaps"
require "config.plugins"
require "config.sets"
require "config.autocommands"
require "config.abbreviations"
require "config.window-yank"
require "utils.prints"
require "utils.testing_module"

if vim.g.neovide then
  require "config.neovide"
end



-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
