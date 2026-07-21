local M = {}

M.on_attach = function(client, bufnr)
	-- To get this working, consult this post:
	-- https://github.com/mason-org/mason-lspconfig.nvim/issues/545
	local function opt(jump_type)
		return {
			reuse_win = true,
			jump_type,
		}
	end
	local telescope = require 'telescope.builtin'

	require('which-key').add({
		{ '<leader>rr', function() vim.api.nvim_echo({ { "WORKS" }, { "bufnr: "..bufnr } }, false, {}) end,
			buffer = bufnr, desc = "bufnr: "..bufnr },
		{ '<leader>rn', vim.lsp.buf.rename,
			buffer = bufnr, desc = 'LSP: [R]e[n]ame' },
		{ '<leader>ca', vim.lsp.buf.code_action,
			buffer = bufnr, desc = 'LSP: [C]ode [A]ction' },
		{ '<leader>gd', function() telescope.lsp_definitions(opt("vsplit")) end,
			buffer = bufnr, desc = 'LSP: [G]oto [D]efinition' },
		{ '<leader>gr', function() telescope.lsp_references(opt("tab")) end,
			buffer = bufnr, desc = 'LSP: [G]oto [R]eferences' },
		{ '<leader>gI', function() telescope.lsp_implementations(opt('tab')) end,
			buffer = bufnr, desc = 'LSP: [G]oto [I]mplementation' },
		{ '<leader>D', require('telescope.builtin').lsp_type_definitions,
			buffer = bufnr, desc = 'LSP: Type [D]efinition' },
		-- { '<leader>ds', require('telescope.builtin').lsp_document_symbols,
		-- 	buffer = bufnr, desc = 'LSP: [D]ocument [S]ymbols' },
		{ '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
			buffer = bufnr, desc = 'LSP: [W]orkspace [S]ymbols' },
		{ '<leader>wd', require('telescope.builtin').lsp_document_symbols,
			buffer = bufnr, desc = 'LSP: [W]orkspace [D]ocument Symbols' },
		{ '<leader>gt', function() telescope.lsp_type_definitions(opt("tab")) end,
			buffer = bufnr, desc = 'LSP: [G]o to type definitions' },
		{ 'K', vim.lsp.buf.hover,
			buffer = bufnr, desc = 'LSP: Hover Documentation' },
		{ '<C-k>', vim.lsp.buf.signature_help,
			buffer = bufnr, desc = 'LSP: Signature Documentation' },
		{ '<leader>gD', function() vim.lsp.buf.declaration(opt()) end,
			buffer = bufnr, desc = 'LSP: [G]oto [D]eclaration' },
		{ '<leader>wa', vim.lsp.buf.add_workspace_folder,
			buffer = bufnr, desc = 'LSP: [W]orkspace [A]dd Folder' },
		{ '<leader>wr', vim.lsp.buf.remove_workspace_folder,
			buffer = bufnr, desc = 'LSP: [W]orkspace [R]emove Folder' },
		{ '<leader>wl',
			function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
			buffer = bufnr, desc = 'LSP: [W]orkspace [L]ist Folders' }
	})
end

return M
