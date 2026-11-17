-- Loaded with --cmd before init.lua: record warnings and errors raised while the
-- config starts up, for scripts/check/spec.lua.
_G.PluginCheck = { notifications = {} }

local notify = vim.notify
vim.notify = function(msg, level, opts)
	if level and level >= vim.log.levels.WARN then
		table.insert(PluginCheck.notifications, tostring(msg))
	end
	return notify(msg, level, opts)
end
