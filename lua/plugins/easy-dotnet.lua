local M = {
	"GustavEikaas/easy-dotnet.nvim"
}

M.dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', }
M.config = function()
	require("easy-dotnet").setup()

	-- require("nvim-tree").setup({
	-- 	on_attach = function(bufnr)
	-- 		local api = require('nvim-tree.api')
	--
	-- 		vim.keymap.set('n', 'A', function()
	-- 			local node = api.tree.get_node_under_cursor()
	-- 			local path = node.type == "directory" and node.absolute_path or vim.fs.dirname(node.absolute_path)
	-- 			require("easy-dotnet").create_new_item(path)
	-- 		end, {
	-- 			desc = 'nvim-tree: Create file from dotnet template',
	-- 			buffer = bufnr,
	-- 			noremap = true,
	-- 			silent = true,
	-- 			nowait = true
	-- 		})
	-- 	end
 --  })
end

return M
