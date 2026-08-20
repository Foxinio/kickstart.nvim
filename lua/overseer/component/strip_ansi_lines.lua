return {
	desc = "Strip ANSI escape sequences before line parsers consume output",
	constructor = function()
		return {
			on_output_lines = function(_, _, lines)
				local remove_ansi = require("overseer.util").remove_ansi
				for index, line in ipairs(lines) do
					lines[index] = remove_ansi(line)
				end
			end,
		}
	end,
}
