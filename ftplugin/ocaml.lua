vim.bo.autoindent = false
vim.bo.smartindent = false
vim.bo.cindent = false

local ocp_indent = vim.fn.expand('~/.opam/default/share/ocp-indent/vim')
if vim.fn.isdirectory(ocp_indent) == 1 then
	vim.opt.rtp:prepend(ocp_indent)
end
