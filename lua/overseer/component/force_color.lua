return {
	desc = "Ask commands to emit colored output",
	constructor = function()
		return {
			on_init = function(_, task)
				task.env = vim.tbl_extend("keep", task.env or {}, {
					CLICOLOR = "YES",
					CLICOLOR_FORCE = "YES",
					FORCE_COLOR = "1",
				})
			end,
		}
	end,
}

