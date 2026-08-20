local lint_script = "~/.local/bin/lint.sh"

local function lint_task(name, args)
	return {
		name = name,
		cmd = lint_script,
		args = args or {},
		cwd = vim.fn.getcwd(),
		components = {
			"default",
		},
	}
end

local M = {
	name = "lint",
}

M.generator = function()
	return {
		{
			name = "lint",
			desc = "Run the project lint script",
			builder = function()
				return lint_task("lint")
			end,
		},
		{
			name = "lint fix",
			desc = "Run the project lint script with --fix",
			builder = function()
				return lint_task("lint fix", { "--fix" })
			end,
		},
	}
end

if vim.fn.filereadable(vim.fn.expand(lint_script)) == 1 then
	return M
else
	return {}
end
