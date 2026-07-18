local M = {
	"folke/noice.nvim",
}

M.dependencies = {
	"MunifTanjim/nui.nvim",
	"rcarriga/nvim-notify",
}

M.lazy = false

M.opts = {
	routes = {
		{
			filter = { event = "msg_show", find = "fewer lines" },
			opts = { skip = true },
		},
		{
			filter = { event = "msg_show", find = "more lines" },
			opts = { skip = true },
		},
		{
			filter = { event = "msg_show", find = "lines yanked" },
			opts = { skip = true },
		},
		-- Hide write messages
		{
			filter = { event = "msg_show", find = "written" },
			opts = { skip = true },
		},
		-- Hide search count
		{
			filter = { event = "msg_show", kind = "search_count" },
			opts = { skip = true },
		},
		-- {
		-- 	filter = {
		-- 		event = "msg_show",
		-- 		kind = "",
		-- 	},
		-- 	view = "cmdline_output",
		-- },
	},
	messages = {
		enabled = true,
		view_history = "messages",
	},
	lsp = {
		override = {
			-- override the default lsp markdown formatter with Noice
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			-- override the lsp markdown formatter with Noice
			["vim.lsp.util.stylize_markdown"] = true,
			-- override cmp documentation with Noice (needs the other options to work)
			["cmp.entry.get_documentation"] = true,
		},
	},
	presets = {
		command_palette = true,
		long_message_to_split = true,
		lsp_doc_border = true,
	},
}

M.keys = {
	{ "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Noice Dismiss" },
	{ "<leader>nh", function() require("noice").cmd("telescope") end, desc = "Noice History" },
}

return M
