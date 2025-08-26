vim.g.mapleader = '\\'
vim.g.maplocalleader = ' '

vim.api.nvim_create_autocmd("User", {
  pattern = "DebugConfigEvent",
  callback = function() end,
  })
vim.api.nvim_create_user_command("TriggerDebugConfig",
	function()
		vim.api.nvim_exec_autocmds("User", { pattern = "DebugConfigEvent" })
	end, {})

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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

require('lazy').setup("plugins", {
  install = { colorscheme = { "tokyonight" } },
  ui = {
    border = "rounded",
  },
  change_detection = { enabled = false },
  checker = { enabled = true },
  debug = false,
})

require "core.bindings"
require "core.plugins"
require "core.sets"
require "core.autocommands"
require "core.abbreviations"
require "core.window-yank"
-- require "core.make-on-save"
require "utils.prints"
require "utils.testing_module"

if vim.g.neovide then
  require "core.neovide"
end



-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
