return {
	"mhartington/formatter.nvim",
	config = function()
		local util = require("formatter.util")

		require("formatter").setup({
			-- Enable or disable logging
			logging = true,
			log_level = vim.log.levels.WARN,

			-- Filetype-specific configurations
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				python = {
					function()
						return {
							exe = "black",
							args = { "--fast", "-", "-l", "120" },
							stdin = true,
						}
					end,
				},
				javascript = {
					require("formatter.filetypes.javascript").prettier,
				},
				typescript = {
					require("formatter.filetypes.typescript").prettier,
				},
				json = {
					require("formatter.filetypes.json").prettier,
				},
				markdown = {
					require("formatter.filetypes.markdown").prettier,
				},
				-- go = {
				-- 	require("formatter.filetypes.go").gofmt,
				-- },
				rust = {
					require("formatter.filetypes.rust").rustfmt,
				},
				cpp = {
					require("formatter.filetypes.cpp").clangformat,
				},
				ocaml = {
					function()
						return {
							exe = "ocamlformat",
							args = { "--enable-outside-detected-project", "--impl", "-i" },
						}
					end,
				},
				haskell = {
					function()
						return {
							exe = "ormolu",
							args = { "--mode", "inplace" },
							stdin = true,
						}
					end,
				},
				-- Default fallback formatter (e.g., removes trailing whitespace)
				["*"] = {
					function()
						return {
							exe = "sed",
							args = { "-i", "'s/[ \t]*$//'" },
							stdin = false,
						}
					end,
				},
			},
		})

		-- Autoformat on save for supported filetypes
		-- vim.api.nvim_create_autocmd("BufWritePost", {
		-- 	pattern = { "*.py", "*.js", "*.ts", "*.json", "*.md", "*.lua", "*.go", "*.rs", "*.ml", "*.hs", "*.cpp" },
		-- 	command = "FormatWrite",
		-- })

		-- Function to run formatter for a given range
		local function format_range(start_line, end_line)
			local filetype = vim.bo.filetype
			local formatter_map = {
				python = "black --fast -",
				lua = "stylua --stdin-filepath . -",
				javascript = "prettier --stdin-filepath .",
				typescript = "prettier --stdin-filepath .",
				json = "prettier --stdin-filepath .",
				markdown = "prettier --stdin-filepath .",
				go = "gofmt",
				rust = "rustfmt",
				cpp = "clang-format",
				ocaml = "ocamlformat --enable-outside-detected-project --impl",
				haskell = "ormolu --mode inplace"
			}

			local formatter_cmd = formatter_map[filetype]
			if formatter_cmd then
				vim.cmd(string.format("silent %d,%d!%s", start_line, end_line, formatter_cmd))
			else
				print("No range formatter available for " .. filetype)
			end
		end

		-- Create :Format command (supports range)
		vim.api.nvim_create_user_command("Format", function(opts)
			if opts.range == 0 then
				-- No range provided, format the whole file
				vim.cmd("FormatWrite")
			else
				-- Format only the selected range
				format_range(opts.line1, opts.line2)
			end
		end, { range = true })

		-- Normal mode keybinding (format whole file)
		vim.keymap.set("n", "<leader>f", "<cmd>Format<CR>", { noremap = true, silent = true, desc = "Format entire file" })

		-- Visual mode keybinding (format selection)
		vim.keymap.set("x", "<leader>f", "<cmd>Format<CR>", { noremap = true, silent = true, desc = "Format selection" })
	end,
}
