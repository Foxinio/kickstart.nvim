return {
  'Brychlikov/fram.nvim',
  name = 'vimplugin-fram.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('fram').setup()
    vim.lsp.enable('framls')
  end,
}
