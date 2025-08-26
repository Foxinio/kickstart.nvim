-- # LSP Configuration & Plugins

local icons = require("utils.icons")

-- Specific server configuration
local servers = {
	rust_analyzer = { },
	ocamllsp = {
		single_file_support = true,
	},
	hls = { },
	pyright = {
		openFilesOnly = false,
		analysis = {
			autoSearchPaths = true,
			useLibraryCodeForTypes = true,
			autoImportCompletions = true,
			diagnosticMode = 'workspace',
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
				functionReturnTypes = true,
				genericTypes = true,
			},
			diagnosticSeverityOverrides = {
				reportAny = false,
				reportUnusedCallResult = false,
				reportMissingTypeArgument = false,
				reportMissingParameterType = false,
				reportUnknownArgumentType = false,
				reportUnknownLambdaType = false,
				reportUnknownMemberType = false,
				reportUnknownParameterType = false,
				reportUnknownVariableType = false
			}
		},
		typeCheckingMode = "off",
	},

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
			diagnostics = {
				disable = { 'missing-fields' },
				globals = { "vim" },
			},
		},
		single_file_support = true,
		log_level = vim.lsp.protocol.MessageType.Warning,
	},
}

-- General options configuration
local opts = {
	diagnostics = {
		underline = true,
		update_in_insert = false,
		virtual_text = {
			spacing = 4,
			source = "if_many",
			prefix = "●",
		},
		severity_sort = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = icons.lsp_signs.Error,
				[vim.diagnostic.severity.WARN] = icons.lsp_signs.Warn,
				[vim.diagnostic.severity.HINT] = icons.lsp_signs.Hint,
				[vim.diagnostic.severity.INFO] = icons.lsp_signs.Info,
			},
		},
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	},
	capabilities = {},
	inlay_hints = {
		enabled = true,
	},
	format = {
		formatting_options = nil,
		timeout_ms = nil,
	},
	servers = servers,
}

local function on_attach(client, bufnr)
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

local config = function()
	vim.diagnostic.config(opts.diagnostics)

	require('lazydev').setup()

	vim.lsp.config("*", {
		capabilities = opts.capabilities,
		on_attach = on_attach,
	})

	require("mason").setup()
	require("mason-lspconfig").setup {
		automatic_enable = false,
		ensure_installed = vim.tbl_keys(servers),
	}
	local lspconfig = require 'lspconfig'

	for server_name, _ in pairs(servers) do
		require('lspconfig')[server_name].setup {
			capabilities = opts.capabilities,
			settings = servers[server_name] or {},
			on_attach = on_attach,
		}
	end

	-- Special-attention servers
	lspconfig.clangd.setup {
		init_options = {
			fallbackFlags = { '--std=c23' }
		},
		on_attach = on_attach,
	}
end

return {
	'neovim/nvim-lspconfig',
	dependencies = {
		'folke/lazydev.nvim',
		"hrsh7th/cmp-nvim-lsp",
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',

		{
			'j-hui/fidget.nvim',
			opts = {},
		},

		{
			"antosha417/nvim-lsp-file-operations",
			config = true,
		},
	},
	opts = opts,
	config = config
}
