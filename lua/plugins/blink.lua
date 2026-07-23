
local M = {
	"saghen/blink.cmp",
	-- enabled = false,
}

M.version = "1.*"
M.build = 'cargo build --release'
M.dependencies = {
	-- Providers
	"folke/lazydev.nvim",
	"Exafunction/windsurf.nvim",

	-- Snippet Engine & its associated nvim-cmp source
	'L3MON4D3/LuaSnip',

	'hrsh7th/nvim-cmp',
}

M.appearance = {
	-- use_nvim_cmp_as_default = false,
	nerd_font_variant = "mono",
}

-- TODO:  Configure command line completion
M.opts = {}
M.opts.cmdline = {
	keymap = {
		-- This tells blink to use your custom logic instead of the 'cmdline' preset
		preset = 'super-tab',

		-- Custom Tab logic to handle ghost text acceptance
	['<C-space>'] = {
		function(cmp)
			if has_words_before() or cmp.is_visible() then
				return cmp.select_and_accept()
			else
				return cmp.show()
			end
		end, "fallback"
	},
	["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	["<Tab>"] = {
		function(cmp)
			if cmp.is_menu_visible() then
				return cmp.select_next()
			end
			return cmp.show()
		end, "fallback"
	},
	["<CR>"] = {
		-- to prevent accepting anytime there is a ghost_text, this is a function
		function (cmp)
			if cmp.is_menu_visible() then
				return cmp.accept()
			end
		end, "fallback" },
	["<PageUp>"] = { "scroll_documentation_up", "fallback" },
	["<PageDown>"] = { "scroll_documentation_down", "fallback" },
	['<Up>'] = { 'select_prev', 'fallback' },
	['<Down>'] = { 'select_next', 'fallback' },
	['<Left>'] = { function(cmp) cmp.hide() end, "fallback" },
	['<Right>'] = { function(cmp) cmp.hide() end, "fallback" },

	},
	completion = {
		menu = { auto_show = false }, -- Set to false if you only want it on Tab
		ghost_text = { enabled = true },
		trigger = {
			show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
		},
		list = {
			selection = { preselect = true, auto_insert = true },
		},
	}
}

M.opts.completion = {
	keyword = { range = 'prefix' },
	trigger = {
		show_on_trigger_character = true;
		show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
	},
	documentation = { auto_show = true },
	list = {
		selection = { preselect = true, auto_insert = false },
	},
	accept = {
		auto_brackets = { enabled = false },
	},
	menu = { auto_show = false },
	ghost_text = { enabled = true },
}
M.opts.fuzzy = { implementation = "prefer_rust_with_warning" }

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
M.opts.keymap = {
	preset = "default",
	['<C-space>'] = {
		function(cmp)
			if has_words_before() or cmp.is_visible() then
				return cmp.select_and_accept()
			else
				return cmp.show()
			end
		end, "fallback"
	},
	["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	["<Tab>"] = {
		function(cmp)
			if cmp.is_menu_visible() then
				return cmp.select_next()
			elseif cmp.snippet_active() then
				return cmp.snippet_forward()
			elseif has_words_before() then
				return cmp.show()
			end
		end, "fallback"
	},
	["<CR>"] = {
		-- to prevent accepting anytime there is a ghost_text, this is a function
		function (cmp)
			if cmp.is_menu_visible() then
				return cmp.accept()
			end
		end, "fallback" },
	["<Esc>"] = { function(cmp) cmp.hide() end, "fallback" },
	["<PageUp>"] = { "scroll_documentation_up", "fallback" },
	["<PageDown>"] = { "scroll_documentation_down", "fallback" },
	['<Up>'] = { 'select_prev', 'fallback' },
	['<Down>'] = { 'select_next', 'fallback' },
	['<Left>'] = { function(cmp) cmp.hide() end, "fallback" },
	['<Right>'] = { function(cmp) cmp.hide() end, "fallback" },

	['<C-e>'] = { 'show_signature', 'hide_signature', 'fallback' },
	['<C-k>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
	-- Unused bindings from previous configuration
	-- ['<C-n>'] = { "select_next", "fallback" },
	-- ['<C-p>'] = { "select_prev", "fallback" },
	-- ['<C-y>'] = same as <C-space>
}

M.opts.cmdline = {
	keymap = {
		-- This tells blink to use your custom logic instead of the 'cmdline' preset
		preset = 'super-tab',

		-- Custom Tab logic to handle ghost text acceptance
	['<C-space>'] = {
		function(cmp)
			if has_words_before() or cmp.is_visible() then
				return cmp.select_and_accept()
			else
				return cmp.show()
			end
		end, "fallback"
	},
	["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	["<Tab>"] = {
		function(cmp)
			if cmp.is_menu_visible() then
				return cmp.select_next()
			end
			return cmp.show()
		end, "fallback"
	},
	["<CR>"] = {
		-- to prevent accepting anytime there is a ghost_text, this is a function
		function (cmp)
			if cmp.is_menu_visible() then
				return cmp.accept()
			end
		end, "fallback" },
	["<PageUp>"] = { "scroll_documentation_up", "fallback" },
	["<PageDown>"] = { "scroll_documentation_down", "fallback" },
	['<Up>'] = { 'select_prev', 'fallback' },
	['<Down>'] = { 'select_next', 'fallback' },
	['<Left>'] = { function(cmp) cmp.hide() end, "fallback" },
	['<Right>'] = { function(cmp) cmp.hide() end, "fallback" },

	},
	completion = {
		menu = { auto_show = false }, -- Set to false if you only want it on Tab
		ghost_text = { enabled = true },
		trigger = {
			show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
		},
		list = {
			selection = { preselect = true, auto_insert = true },
		},
	}
}

M.opts.sources = {
	-- add lazydev to your completion providers
	default = {
		"lazydev",
		"lsp",
		"path",
		-- "snippets",
		"buffer",
		"codeium",
	},
	providers = {
		codeium = {
			name = 'Codeium',
			module = 'codeium.blink',
			async = true
		},
		lazydev = {
			name = "LazyDev",
			module = "lazydev.integrations.blink",
			score_offset = 100,
		},
	},
	transform_items = function(_, items)
		return vim.tbl_filter(function(item)
			return item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
		end, items)
	end,
}

M.opts.snippets = { preset = 'luasnip' }

return M
