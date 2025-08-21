return {
  {
    "joom/latex-unicoder.vim",
		-- enable = false,
    config = function()
      -- Rebind <C-l> to <leader>l in normal mode
      vim.api.nvim_set_keymap("n", "<leader>l", "<Plug>LatexUnicoder", { noremap = false, silent = true })

      -- Unmap the default <C-l> binding
      -- vim.api.nvim_del_keymap("n", "<C-l>")
    end
  }
}

