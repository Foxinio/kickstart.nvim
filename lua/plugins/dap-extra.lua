-- nvim-dap extras: GDB-style REPL commands and history, cppdbg defaults,
-- virtual text and signs, local frame view. The UI lives in dap-ui.lua.
local M = { 'Foxinio/nvim-dap-extra.nvim' }

-- Loaded as a dependency of nvim-dap (debug.lua), never at startup.
M.lazy = true
M.module = false

M.dependencies = { 'mfussenegger/nvim-dap', 'theHamsta/nvim-dap-virtual-text' }

M.opts = {}

return M
