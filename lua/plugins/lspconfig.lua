-- LSP Configuration & Plugins
-- local lst_signs = require('utils.lsp_texts').lsp_signs;

return {
	'neovim/nvim-lspconfig',
	dependencies = {
		-- Automatically install LSPs to stdpath for neovim
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',

		-- Useful status updates for LSP
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ 'j-hui/fidget.nvim', opts = {} },

		-- Additional lua configuration, makes nvim stuff amazing!
		'folke/neodev.nvim',
	},
  opts = {
		-- options for vim.diagnostic.config()
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
				-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
				-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
				-- prefix = "icons",
			},
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = require('utils.lsp_texts').lsp_signs.Error,
					[vim.diagnostic.severity.WARN] = require('utils.lsp_texts').lsp_signs.Warn,
					[vim.diagnostic.severity.HINT] = require('utils.lsp_texts').lsp_signs.Hint,
					[vim.diagnostic.severity.INFO] = require('utils.lsp_texts').lsp_signs.Info,
				},
			},
		},
		-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
		-- Be aware that you also will need to properly configure your LSP server to
		-- provide the inlay hints.
		inlay_hints = {
			enabled = true,
		},
		-- add any global capabilities here
		capabilities = {},
		-- options for vim.lsp.buf.format
		-- `bufnr` and `filter` is handled by the LazyVim formatter,
		-- but can be also overridden when specified
		format = {
			formatting_options = nil,
			timeout_ms = nil,
		},
		-- LSP Server Settings
		servers = {
			lua_ls = {
				settings = {
					clangd = {},
					-- gopls = {},
					pyright = {},
					rust_analyzer = {},
					tsserver = {},
					-- html = { filetypes = { 'html', 'twig', 'hbs'} },

					ocamllsp = {
						single_file_support = true,
					},
					lua_ls = {
						Lua = {
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
							-- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							diagnostics = {
								-- disable = { 'missing-fields' },
								globals = { "vim" },
							},
						},
					},
				},
			},
		},
	},
	config = function ()

		local on_attach = function(client, bufnr)
			local nmap = function(keys, func, desc)
				if desc then
					desc = 'LSP: ' .. desc
				end
				vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
			end
			local xmap = function(keys, func, desc)
				if desc then
					desc = 'LSP: ' .. desc
				end
				vim.keymap.set('x', keys, func, { buffer = bufnr, desc = desc })
			end

			local function opt(jump_type)
				return {
					reuse_win = true,
					jump_type,
				}
			end

			local telescope = require 'telescope.builtin'

			nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
			nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
			nmap('<leader>gd', function() telescope.lsp_definitions(opt("vsplit")) end, '[G]oto [D]efinition')
			nmap('<leader>gr', function() telescope.lsp_references(opt("tab")) end, '[G]oto [R]eferences')
			nmap('<leader>gI', function() telescope.lsp_implementations(opt('tab')) end, '[G]oto [I]mplementation')
			nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
			nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
			nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
			nmap('<leader>wd', require('telescope.builtin').lsp_document_symbols, '[W]orkspace [D]ocument Symbols')
			nmap('<leader>gt', function() telescope.lsp_type_definitions(opt("tab")) end, '[G]o to type definitions')
			nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
			nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

			-- Lesser used LSP functionality
			--
			nmap('<leader>gD', function() vim.lsp.buf.declaration(opt()) end, '[G]oto [D]eclaration')
			nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
			nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
			nmap('<leader>wl', function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, '[W]orkspace [L]ist Folders')

			-- Create a command `:Format` local to the LSP buffer
			vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
				vim.lsp.buf.format()
			end, { desc = 'Format current buffer with LSP' })

			nmap('<leader>f', vim.lsp.buf.format, 'format current buffer with lsp')
			xmap('<leader>f', vim.lsp.buf.format, 'format current buffer with lsp')

			if type(client.resolved_capabilities) == "table" then
				if client.resolved_capabilities.code_lens then
						local codelens = vim.api.nvim_create_augroup(
								'LSPCodeLens',
								{ clear = true }
						)
						vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'CursorHold' }, {
								group = codelens,
								callback = function()
										vim.lsp.codelens.refresh()
								end,
								buffer = bufnr,
						})
			  end
			end

		end

		-- document existing key chains
		require('which-key').register {
			['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
			['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
			['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
			['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
			['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
			['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
			['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
			['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
		}
		-- register which-key VISUAL mode
		-- required for visual <leader>hs (hunk stage) to work
		require('which-key').register({
			['<leader>'] = { name = 'VISUAL <leader>' },
			['<leader>h'] = { 'Git [H]unk' },
		}, { mode = 'v' })

		require('mason').setup()
		require('mason-lspconfig').setup()

		local servers = {
			clangd = {},
			-- gopls = {},
			pyright = {},
			rust_analyzer = {},
			tsserver = {},
			html = { filetypes = { 'html', 'twig', 'hbs'} },

			ocamllsp = {},
			lua_ls = {
				Lua = {
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
					diagnostics = {
						disable = { 'missing-fields' },
						globals = { "vim" },
					},
				},
			},
		}

		-- Setup neovim lua configuration
		require('neodev').setup()

		-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Ensure the servers above are installed
		local mason_lspconfig = require 'mason-lspconfig'

		mason_lspconfig.setup {
			ensure_installed = vim.tbl_keys(servers),
		}

		mason_lspconfig.setup_handlers {
			function(server_name)
				require('lspconfig')[server_name].setup {
					capabilities = capabilities,
					on_attach = on_attach,
					settings = servers[server_name],
					filetypes = (servers[server_name] or {}).filetypes,
				}
			end,
		}
	end
}
