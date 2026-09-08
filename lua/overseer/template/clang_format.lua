local function task(name, mode)
	return {
		name = name,
		cmd = "find ./src -regextype posix-egrep -regex '.*(\\.cpp|\\.h)' -print0"
			.. " | xargs -0 -r clang-format-19 " .. mode .. " --Werror",
		cwd = vim.fn.getcwd(),
	}
end

local M = {
	name = "clang-format",
}

M.generator = function()
	return {
		{
			name = "clang-format: check src",
			builder = function()
				return task("clang-format: check src", "--dry-run")
			end,
		},
		{
			name = "clang-format: format src",
			builder = function()
				return task("clang-format: format src", "-i")
			end,
		},
	}
end

return M
