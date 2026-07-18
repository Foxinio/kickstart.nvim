local M = {
  'Brychlikov/fram.nvim',
}

M.name = 'vimplugin-fram.nvim'

M.dependencies = {
  'nvim-treesitter/nvim-treesitter',
}

M.opts = {}

M.config = function(_, opts)
  require('fram').setup(opts)
  vim.lsp.enable('framls')
end

return M
