local M = {}
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2))))

function M.resource(path)
	return root .. '/' .. path
end

function M.setup(opts)
	require('verilator-dev.debug').setup(opts)
	for name, callback in pairs({
		VerilatorRegress = function() require('verilator-dev.regression').run() end,
		VerilatorHtml = function(args) require('verilator-dev.ast').html(args.fargs) end,
		VerilatorDiff = function(args) require('verilator-dev.ast').diff(args.fargs) end,
	}) do
		vim.api.nvim_create_user_command(name, function(args)
			local ok, err = pcall(callback, args)
			if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
		end, { nargs = name == 'VerilatorRegress' and 0 or '*', force = true })
	end
end

return M
