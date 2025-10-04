
local M = {
	"saghen/blink.cmp",
}

M.build = 'cargo build --release'
M.dependencies = {
	-- Providers
	"folke/lazydev.nvim",
	{ 'saghen/blink.compat', version = '2.*', },
	'kdheepak/cmp-latex-symbols',
	'Exafunction/windsurf.nvim',
	-- "GustavEikaas/easy-dotnet.nvim",

	-- Snippet Engine & its associated nvim-cmp source
	'L3MON4D3/LuaSnip',
}

M.opts = {}
M.opts.completion = {
	keyword = { range = 'prefix' },
	trigger = {
		show_on_trigger_character = true;
		show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
	},
	documentation = { auto_show = true },
	list = {
		selection = { preselect = false, auto_insert = false },
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
			if cmp.is_visible() then
				return cmp.select_next()
			elseif cmp.snippet_active() then
				return cmp.snippet_forward()
			elseif has_words_before() then
				return cmp.show()
			end
		end, "fallback"
	},
	["<CR>"] = { "accept", "fallback" },
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

M.opts.sources = {
	-- add lazydev to your completion providers
	default = {
		"lazydev",
		"lsp",
		-- "latex",
		"latex_symbols",
		"path",
		"snippets",
		"buffer",
		"codeium",
	},
	providers = {
		codeium = {
			name = 'Codeium',
			module = 'codeium.blink',
			async = true
		},
		["easy-dotnet"] = {
			name = "easy-dotnet",
			enabled = true,
			module = "easy-dotnet.completion.blink",
			score_offset = 10000,
			async = true,
		},
		lazydev = {
			name = "LazyDev",
			module = "lazydev.integrations.blink",
			score_offset = 100,
		},
		latex = {
			name = "Latex",
			module = "blink-cmp-latex",
			opts = {
				insert_command = false
			},
		},
		latex_symbols = {
			name = "latex_symbols",
			module = 'blink.compat.source',
			opts = {
				strategy = 0,
			},
		},
	},
}

M.opts.snippets = { preset = 'luasnip' }

return M
