local M = {
	"whonore/Coqtail",
}

M.dependencies = {
	'nvim-telescope/telescope.nvim',
}

M.ft = "coq"
M.module = false

M.keys = {
	{ '<M-down>', '<Plug>CoqNext', noremap = true },
	{ '<M-up>', '<Plug>CoqUndo', noremap = true },
}

M.build = function()
	vim.cmd("!pip install --user -r requirements.txt")
end

M.init = function()
	vim.g.filetype_v = "coq"
	vim.filetype.add({
		extension = {
			v = function()
				return vim.g.filetype_v
			end,
		},
	})
	vim.api.nvim_create_user_command("VFiletypeVerilog", function()
		vim.g.filetype_v = "verilog"
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.api.nvim_buf_is_loaded(buf) and vim.fn.fnamemodify(name, ":e") == "v" then
				vim.bo[buf].filetype = "verilog"
			end
		end
	end, {})
	vim.g.coqtail_noindent = 1
	vim.g.coqtail_noindent_comment = 1
	vim.g.coqtail_auto_set_proof_diffs = 'on'

	vim.api.nvim_create_autocmd('FileType', {
		pattern = { 'coq', 'coq-infos', 'coq-goals' },
		callback = function()
			vim.opt_local.spell = false
			vim.api.nvim_set_hl(0, "CoqtailChecked", {
				bg = "#1c4d29",
			})
		end
	})

end

return M
