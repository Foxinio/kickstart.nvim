local M = {
	"whonore/Coqtail",
}

M.dependencies = {
	'nvim-telescope/telescope.nvim',
}

M.event = "FileType coq"
M.module = false

M.build = function()
	vim.cmd("!pip install --user -r requirements.txt")
end

M.config = function()
	-- Coqtail's detector forces empty .v files to coq even after VFiletypeVerilog.
	vim.api.nvim_clear_autocmds({ group = 'filetypedetect', event = { 'BufRead', 'BufNewFile' }, pattern = '*.v' })
end

M.init = function()
	vim.g.filetype_v = "verilog"
	vim.api.nvim_create_user_command("VFiletypeCoq", function()
		vim.g.filetype_v = "coq"
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.api.nvim_buf_is_loaded(buf) and vim.fn.fnamemodify(name, ":e") == "v" then
				vim.bo[buf].filetype = "coq"
			end
		end
	end, {})
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
		callback = function(args)
			vim.opt_local.spell = false
			if args.match == 'coq' then
				vim.keymap.set('n', '<M-down>', '<Plug>CoqNext', { buffer = args.buf })
				vim.keymap.set('n', '<M-up>', '<Plug>CoqUndo', { buffer = args.buf })
			end
			vim.api.nvim_set_hl(0, "CoqtailChecked", {
				bg = "#1c4d29",
			})
		end
	})

end

return M
