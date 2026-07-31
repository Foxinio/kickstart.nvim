-- # LSP Configuration & Plugins

local icons = require("utils.icons")

--[[ Plugin for managing LSP conguration ]]
local M = {
	'neovim/nvim-lspconfig',
	-- version = '2.9.*',
}

M.dependencies = {
	'folke/lazydev.nvim',
	"hrsh7th/cmp-nvim-lsp",
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',

	{
		'j-hui/fidget.nvim',
		opts = {
			notification = { window = { avoid = { "NvimTree" }, }, },
		}
	},

	{
		"igorlfs/nvim-lsp-file-operations",
		config = true,
	},
}

local required_servers = {
	"clangd",
	"pyright",
	"lua_ls",
}

-- Specific server configuration
local servers = {
	clangd = {},
	rust_analyzer = { },
	-- csharp_ls = { },
	ocamllsp = {
		single_file_support = true,
	},
	clangd = {
		init_options = {
			fallbackFlags = { '--std=c++23' }
		},
	},
	hls = { },
	coq_lsp = { },
	texlab = { },
	pyright = {
		settings = {
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
	},
	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = 'Disable',
					keywordSnippet = 'Disable',
				},
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
	},
}

-- General options configuration
M.opts = {
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
	mason_lspconfig = {
		automatic_enable = true,
		ensure_installed = required_servers,
	},
	servers = servers,
}

M.config = function(_, opts)
	vim.diagnostic.config(opts.diagnostics)

	require('lazydev').setup()

	-- vim.lsp.config("*", {
	-- 	capabilities = M.opts.capabilities,
	-- 	on_attach = on_attach,
	-- })

	require("mason").setup()
	require("mason-lspconfig").setup(opts.mason_lspconfig)

	opts.capabilities = require('blink.cmp').get_lsp_capabilities({
		textDocument = { completion = { completionItem = { snippetSupport = false }, }, },
	})

	for server_name, settings in pairs(servers) do
		vim.lsp.config(server_name, {
			-- init_options = settings.init_options or {},
			capabilities = opts.capabilities or {},
			settings = settings or {},
			on_attach = require("utils.lsp-on-attach").on_attach,
		})
		vim.lsp.enable(server_name)
	end

	-- Special-attention servers
	vim.api.nvim_create_user_command("LspSetupC", function()
		vim.lsp.config.clangd.init_options = {
			fallbackFlags = { '--std=c23' }
		}
		vim.lsp.enable("clangd")
    vim.cmd("LspStart clangd")
	end, {})
	vim.api.nvim_create_user_command("LspSetupCpp", function()
		vim.lsp.config.clangd.init_optiosn = {
			fallbackFlags = { '--std=c++23' }
		}
		vim.lsp.enable("clangd")
    vim.cmd("LspStart clangd")
	end, {})

end

return M
