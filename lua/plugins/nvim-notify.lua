return {
	"foxinio/nvim-notify",
	config = function()
		local notify = require "notify"
		notify.setup({
			stages = "static",
		})
	end
}
