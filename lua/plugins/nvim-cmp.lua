return {
	-- Autocompletion
  enabled = false,
	'hrsh7th/nvim-cmp',
	event = "BufReadPre",
	dependencies = {
		-- Snippet Engine & its associated nvim-cmp source
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',

		-- Adds LSP completion capabilities
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-path',
		"hrsh7th/cmp-cmdline",
		'hrsh7th/cmp-buffer',
		'kdheepak/cmp-latex-symbols',
		-- {
		-- 	'Exafunction/codeium.nvim',
		-- 	dependencies = {
		-- 		"nvim-lua/plenary.nvim",
		-- 	}
		-- },

		-- Adds a number of user-friendly snippets
		'Foxinio/friendly-snippets',
	},
	opts = function()
		local cmp = require 'cmp'
		local luasnip = require 'luasnip'
		require('luasnip.loaders.from_vscode').lazy_load()
		luasnip.config.setup {}

		local cmp_kinds = require('utils.lsp_texts').lsp_kinds

		return {
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			completion = {
				completeopt = 'menu,menuone,noinsert,popup,noselect',
				autocomplete = false,
			},
			formatting = {
				expandable_indicator = true,
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					if vim.tbl_contains({ "path" }, entry.source.name) then
						local icon, hl_group = require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
						if icon then
							vim_item.kind = icon
							vim_item.kind_hl_group = hl_group
							return vim_item
						end
					end
					vim_item.kind = (cmp_kinds[vim_item.kind] or "") .. " " .. vim_item.kind
					return vim_item
				end,
			},

			mapping = cmp.mapping.preset.insert {
				['<C-n>'] = cmp.mapping.select_next_item(),
				['<C-p>'] = cmp.mapping.select_prev_item(),
				['<C-b>'] = cmp.mapping.scroll_docs(-4),
				['<C-f>'] = cmp.mapping.scroll_docs(4),
				["<C-y>"] = cmp.mapping(function(fallback)
					if not cmp.visible() then
						cmp.complete()                     -- Open completion menu
					end
					if cmp.get_selected_entry() == nil then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })  -- Select first item
					end
					cmp.confirm({ select = true })       -- Confirm the selected item
				end, { "i", "s" }),
				['<C-Space>'] = cmp.mapping(function(fallback)
					if not cmp.visible() then
						cmp.complete()                     -- Open completion menu
					end
					if cmp.get_selected_entry() == nil then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })  -- Select first item
					end
					cmp.confirm({ select = true })       -- Confirm the selected item
				end, { 'i', 's' }),
				['<CR>'] = cmp.mapping.confirm {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
				['<Right>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					fallback()
				end, { 'i', 's' }),
				['<Left>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					end
					fallback()
				end, { 'i', 's' }),
				['<Down>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end, { 'i', 's' }),
				['<Tab>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { 'i', 's' }),
				['<Up>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { 'i', 's' }),
				['<S-Tab>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { 'i', 's' }),
			},

			sources = {
				{ name = 'nvim_lsp' },
				-- { name = 'copilot' },
				{ name = 'latex_symbols', option = { strategy = 0 } },
				{ name = 'path' },
				{ name = 'buffer' },
				{ name = 'luasnip' },
			},

			window = {
				completion = {
					border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
				},
				documentation = {
					border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
				},
			},

			experimental = {
				ghost_text = {
					hl_group = "LspCodeLens",
				},
			},
		}
	end,

	setup = function(_, opts)
		local cmp = require("cmp")
		cmp.setup(opts)

		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end,
}
