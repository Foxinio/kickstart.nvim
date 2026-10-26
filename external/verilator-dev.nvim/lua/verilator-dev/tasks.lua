local M = {}

function M.environment()
	return {
		TERM = "xterm-256color", FORCE_COLOR = "1", CLICOLOR = "YES", CLICOLOR_FORCE = "YES",
		CMAKE_COLOR_DIAGNOSTICS = "ON", GTEST_COLOR = "1", PY_COLORS = "1",
	}
end

function M.components()
	require('ansi-colorize.overseer').preserve_overseer_ansi()
	return {
		{ "ansi_colorize", mode = "conceal", on = "output" },
		"on_exit_set_status", "on_complete_notify",
	}
end

return M
