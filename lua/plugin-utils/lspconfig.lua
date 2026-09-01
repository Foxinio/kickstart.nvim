local M = {}

M.on_attach = function(client, bufnr)
	-- To get this working, consult this post:
	-- https://github.com/mason-org/mason-lspconfig.nvim/issues/545
	local telescope = require 'telescope.builtin'

	local function telescope_jump(picker, jump_type)
		return function()
			picker({ jump_type = jump_type })
		end
	end

	local function telescope_float(picker)
		return function()
			require('float-command').open_telescope(picker)
		end
	end

	local function lsp_jump(action, open_cmd)
		return function()
			if open_cmd then
				vim.cmd(open_cmd)
			end
			action()
		end
	end

	require('which-key').add({
		{ '<leader>rr', function() vim.api.nvim_echo({ { "WORKS" }, { "bufnr: "..bufnr } }, false, {}) end,
			buffer = bufnr, desc = "bufnr: "..bufnr },
		{ '<leader>rn', vim.lsp.buf.rename,
			buffer = bufnr, desc = 'LSP: [R]e[n]ame' },
		{ '<leader>ca', vim.lsp.buf.code_action,
			buffer = bufnr, desc = 'LSP: [C]ode [A]ction' },
		{ 'K', vim.lsp.buf.hover,
			buffer = bufnr, desc = 'LSP: Hover Documentation' },
		{ '<C-k>', vim.lsp.buf.signature_help,
			buffer = bufnr, desc = 'LSP: Signature Documentation' },
		{ '<leader>wa', vim.lsp.buf.add_workspace_folder,
			buffer = bufnr, desc = 'LSP: [W]orkspace [A]dd Folder' },
		{ '<leader>wr', vim.lsp.buf.remove_workspace_folder,
			buffer = bufnr, desc = 'LSP: [W]orkspace [R]emove Folder' },
		{ '<leader>wl',
			function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
			buffer = bufnr, desc = 'LSP: [W]orkspace [L]ist Folders' },

		{ '<leader>gd', telescope_jump(telescope.lsp_definitions),
			buffer = bufnr, desc = 'LSP: [G]oto [D]efinition' },
		{ '<leader>gsd', telescope_jump(telescope.lsp_definitions, "split"),
			buffer = bufnr, desc = 'LSP: [G]oto [D]efinition in split' },
		{ '<leader>gvd', telescope_jump(telescope.lsp_definitions, "vsplit"),
			buffer = bufnr, desc = 'LSP: [G]oto [D]efinition in vertical split' },
		{ '<leader>gfd', telescope_float(telescope.lsp_definitions),
			buffer = bufnr, desc = 'LSP: [G]oto [D]efinition in float' },
		{ '<leader>gtd', telescope_jump(telescope.lsp_definitions, "tab"),
			buffer = bufnr, desc = 'LSP: [G]oto [D]efinition in tab' },

		{ '<leader>gr', telescope_jump(telescope.lsp_references),
			buffer = bufnr, desc = 'LSP: [G]oto [R]eferences' },
		{ '<leader>gsr', telescope_jump(telescope.lsp_references, "split"),
			buffer = bufnr, desc = 'LSP: [G]oto [R]eferences in split' },
		{ '<leader>gvr', telescope_jump(telescope.lsp_references, "vsplit"),
			buffer = bufnr, desc = 'LSP: [G]oto [R]eferences in vertical split' },
		{ '<leader>gfr', telescope_float(telescope.lsp_references),
			buffer = bufnr, desc = 'LSP: [G]oto [R]eferences in float' },
		{ '<leader>gtr', telescope_jump(telescope.lsp_references, "tab"),
			buffer = bufnr, desc = 'LSP: [G]oto [R]eferences in tab' },

		{ '<leader>gI', telescope_jump(telescope.lsp_implementations),
			buffer = bufnr, desc = 'LSP: [G]oto [I]mplementation' },
		{ '<leader>gsI', telescope_jump(telescope.lsp_implementations, "split"),
			buffer = bufnr, desc = 'LSP: [G]oto [I]mplementation in split' },
		{ '<leader>gvI', telescope_jump(telescope.lsp_implementations, "vsplit"),
			buffer = bufnr, desc = 'LSP: [G]oto [I]mplementation in vertical split' },
		{ '<leader>gfI', telescope_float(telescope.lsp_implementations),
			buffer = bufnr, desc = 'LSP: [G]oto [I]mplementation in float' },
		{ '<leader>gtI', telescope_jump(telescope.lsp_implementations, "tab"),
			buffer = bufnr, desc = 'LSP: [G]oto [I]mplementation in tab' },

		{ '<leader>gT', telescope_jump(telescope.lsp_type_definitions),
			buffer = bufnr, desc = 'LSP: [G]oto [T]ype definition' },
		{ '<leader>gsT', telescope_jump(telescope.lsp_type_definitions, "split"),
			buffer = bufnr, desc = 'LSP: [G]oto [T]ype definition in split' },
		{ '<leader>gvT', telescope_jump(telescope.lsp_type_definitions, "vsplit"),
			buffer = bufnr, desc = 'LSP: [G]oto [T]ype definition in vertical split' },
		{ '<leader>gfT', telescope_float(telescope.lsp_type_definitions),
			buffer = bufnr, desc = 'LSP: [G]oto [T]ype definition in float' },
		{ '<leader>gtT', telescope_jump(telescope.lsp_type_definitions, "tab"),
			buffer = bufnr, desc = 'LSP: [G]oto [T]ype definition in tab' },

		{ '<leader>ws', telescope_jump(telescope.lsp_dynamic_workspace_symbols),
			buffer = bufnr, desc = 'LSP: [W]orkspace [S]ymbols' },
		{ '<leader>wss', telescope_jump(telescope.lsp_dynamic_workspace_symbols, "split"),
			buffer = bufnr, desc = 'LSP: [W]orkspace [S]ymbols in split' },
		{ '<leader>wvs', telescope_jump(telescope.lsp_dynamic_workspace_symbols, "vsplit"),
			buffer = bufnr, desc = 'LSP: [W]orkspace [S]ymbols in vertical split' },
		{ '<leader>wTs', telescope_jump(telescope.lsp_dynamic_workspace_symbols, "tab"),
			buffer = bufnr, desc = 'LSP: [W]orkspace [S]ymbols in tab' },

		{ '<leader>wd', telescope_jump(telescope.lsp_document_symbols),
			buffer = bufnr, desc = 'LSP: [W]orkspace [D]ocument Symbols' },
		{ '<leader>wsd', telescope_jump(telescope.lsp_document_symbols, "split"),
			buffer = bufnr, desc = 'LSP: [W]orkspace [D]ocument Symbols in split' },
		{ '<leader>wvd', telescope_jump(telescope.lsp_document_symbols, "vsplit"),
			buffer = bufnr, desc = 'LSP: [W]orkspace [D]ocument Symbols in vertical split' },
		{ '<leader>wTd', telescope_jump(telescope.lsp_document_symbols, "tab"),
			buffer = bufnr, desc = 'LSP: [W]orkspace [D]ocument Symbols in tab' },

		{ '<leader>gD', vim.lsp.buf.declaration,
			buffer = bufnr, desc = 'LSP: [G]oto [D]eclaration' },
		{ '<leader>gsD', lsp_jump(vim.lsp.buf.declaration, "split"),
			buffer = bufnr, desc = 'LSP: [G]oto [D]eclaration in split' },
		{ '<leader>gvD', lsp_jump(vim.lsp.buf.declaration, "vsplit"),
			buffer = bufnr, desc = 'LSP: [G]oto [D]eclaration in vertical split' },
		{ '<leader>gfD', function()
			require('float-command').open_lsp(vim.lsp.buf.declaration)
		end, buffer = bufnr, desc = 'LSP: [G]oto [D]eclaration in float' },
		{ '<leader>gtD', lsp_jump(vim.lsp.buf.declaration, "tab split"),
			buffer = bufnr, desc = 'LSP: [G]oto [D]eclaration in tab' },
	})
end

return M
