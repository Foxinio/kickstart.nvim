local M = {}

function M.rerun_as_new(task)
	task:clone():start()
end

function M.clear_list()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ include_ephemeral = true })

	for _, task in ipairs(tasks) do
		task:dispose(true)
	end

	vim.notify(string.format("Disposed %d Overseer tasks", #tasks), vim.log.levels.INFO)
end

function M.setup_output_highlights(bufnr)
	vim.api.nvim_set_hl(0, "OverseerOutputError", { link = "DiagnosticError", default = true })
	vim.api.nvim_set_hl(0, "OverseerOutputWarn", { link = "DiagnosticWarn", default = true })
	vim.api.nvim_set_hl(0, "OverseerOutputInfo", { link = "DiagnosticInfo", default = true })
	vim.api.nvim_set_hl(0, "OverseerOutputOk", { link = "DiagnosticOk", default = true })

	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd([[
			syntax match OverseerOutputError /\c\(error\|failed\|undefined reference\|no such file or directory\)/
			syntax match OverseerOutputWarn /\c\(warning\|deprecated\)/
			syntax match OverseerOutputInfo /^\s*\(Building\|Linking\|Generating\|Configuring\|Scanning dependencies\|Running tests\)/
			syntax match OverseerOutputOk /^\s*\(Built target\|Configuring done\|Generating done\|Build files have been written\|[0-9]\+% tests passed\)/
		]])
	end)
end

return M
