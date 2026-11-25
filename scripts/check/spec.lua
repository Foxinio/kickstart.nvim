-- Config checks for scripts/check/run: start the real config headless, exercise
-- the integrations between it and its plugins, force-load every plugin, and
-- write one "PASS|FAIL|WARN  name: detail" line per check to $CHECK_OUT.
local api = vim.api
local lines = {}
local function report(status, name, detail)
	lines[#lines + 1] = ("%-5s %s%s"):format(status, name, detail and detail ~= "" and (": " .. detail) or "")
end

local function check(name, fn)
	local ok, result = xpcall(fn, debug.traceback)
	if not ok then
		-- First line of the error, without the "file:line: " prefix.
		local msg = tostring(result):gsub("\n.*", ""):gsub("^[^:]*:%d+: ", "")
		report("FAIL", name, msg)
	elseif result == false then
		report("FAIL", name)
	elseif type(result) == "string" then
		report("WARN", name, result)
	else
		report("PASS", name)
	end
end

local function lazy_plugin(name)
	return require("lazy.core.config").plugins[name]
end

local function load(name)
	require("lazy").load({ plugins = { name } })
end

local function close_telescope()
	local prompt = api.nvim_get_current_buf()
	if vim.bo[prompt].filetype == "TelescopePrompt" then
		require("telescope.actions").close(prompt)
	end
end

local function finish()
	local warnings = (PluginCheck and PluginCheck.notifications) or {}
	for _, msg in ipairs(warnings) do
		report("FAIL", "startup notification", msg:gsub("\n", " "):sub(1, 200))
	end
	local messages = api.nvim_exec2("messages", { output = true }).output
	local seen = {}
	for line in vim.gsplit(messages, "\n", { plain = true }) do
		if (line:match("^E%d+:") or line:match("^Error")) and not seen[line] then
			seen[line] = true
			report("FAIL", "error message", line:sub(1, 200))
		end
	end
	local out = assert(io.open(assert(vim.env.CHECK_OUT, "CHECK_OUT not set"), "w"))
	out:write(table.concat(lines, "\n") .. "\n")
	out:close()
	local root = io.open(vim.env.CHECK_ROOT, "w")
	if root then
		root:write(require("lazy.core.config").options.root)
		root:close()
	end
	vim.cmd("qa!")
end

local ok, err = xpcall(function()
	-- Startup: lazy-loaded plugins stay unloaded until their trigger.
	check("all plugins installed", function()
		local missing = {}
		for name, plugin in pairs(require("lazy.core.config").plugins) do
			if not plugin._.installed then
				missing[#missing + 1] = name
			end
		end
		table.sort(missing)
		assert(#missing == 0, "not installed (run :Lazy install): " .. table.concat(missing, ", "))
	end)

	api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
	vim.wait(1500)

	check("Blink preserves Cash command-line fallback", function()
		load("blink.cmp")
		local mapping = vim.fn.maparg("<CR>", "c", false, true)
		assert(mapping.desc and mapping.desc:match("^blink%.cmp:"), "Cash overwrote Blink's Enter mapping")
		local fallback = require("blink.cmp.keymap.fallback").wrap("c", "<CR>")
		assert(fallback() == api.nvim_replace_termcodes("<CR>", true, true, true), "Enter fallback broken")
	end)

	check("Blink command-line completion variants", function()
		dofile(vim.fn.stdpath('config') .. '/scripts/check/blink-cmdline.lua').run()
	end)

	check("overseer stays lazy at startup", function()
		assert(not lazy_plugin("overseer.nvim")._.loaded, "overseer.nvim was loaded during startup")
	end)

	check("LSP server configs", function()
		local pyright = vim.lsp.config.pyright
		assert(pyright and pyright.settings.python.analysis.typeCheckingMode == "off", "pyright settings")
		local clangd = vim.lsp.config.clangd
		assert(clangd and clangd.init_options.fallbackFlags[1] == "--std=c++23", "clangd init_options")
	end)

	check(":Float opens a float", function()
		assert(api.nvim_get_commands({}).Float, ":Float missing")
		vim.cmd("Float echo 'plugin check'")
		local floating = api.nvim_win_get_config(0).relative ~= ""
		vim.cmd("silent! only")
		assert(floating, "no float opened")
	end)

	check("Overseer colours task output", function()
		load("overseer.nvim")
		local components = require("overseer.component")
		for _, name in ipairs({ "force_color", "strip_ansi_lines", "ansi_colorize" }) do
			assert(components.get(name), "component " .. name .. " missing")
		end
		local task = require("overseer").new_task({ cmd = { "printf", "\\033[1;31mred\\033[0m\\033[K\\n" } })
		task:start()
		vim.wait(5000, function()
			return task:is_complete()
		end)
		local line = api.nvim_buf_get_lines(task:get_bufnr(), 0, 1, false)[1]
		assert(task.env and task.env.FORCE_COLOR == "1", "force_color not applied")
		assert(line == "\27[1;31mred\27[0m", "unexpected output line: " .. vim.inspect(line))
		task:dispose(true)
	end)

	check("Telescope editable pickers open", function()
		load("telescope.nvim")
		require("telescope").extensions.editable.find_files()
		vim.wait(500)
		local open = vim.bo.filetype == "TelescopePrompt"
		close_telescope()
		assert(open, "find_files prompt did not open")
	end)

	check("search-replace opens", function()
		require("search_replace").open()
		vim.wait(500)
		local open = vim.bo.filetype == "TelescopePrompt"
		close_telescope()
		assert(open, "search-replace prompt did not open")
	end)

	check("debugger UI (dap-ui fork debug tab + dap-extra)", function()
		load("nvim-dap")
		local dapui = require("dapui")
		assert(dapui.debug_tab and dapui.restore_layout, "dap-ui lacks debug_tab (update the Foxinio fork)")
		assert(api.nvim_get_commands({}).DapClean, ":DapClean missing")
		assert(type(require("dap-extra").local_frame) == "function", "dap-extra lacks local_frame (update it)")
		local breakpoints = require("dap-extra").breakpoints
		assert(type(breakpoints.set_command) == "function", "dap-extra lacks command breakpoints (update it)")
		assert(type(breakpoints.chain) == "function", "dap-extra lacks breakpoint chains (update it)")
		local buf = api.nvim_get_current_buf()
		local editing_tab = api.nvim_get_current_tabpage()
		dapui.open()
		vim.wait(300)
		local in_debug_tab = api.nvim_get_current_tabpage() == dapui.debug_tab.tabpage()
		local win = dapui.debug_tab.source_window()
		dapui.source_window.open(buf, 1, 1)
		local label = vim.wo[win].winbar
		dapui.close()
		api.nvim_set_current_tabpage(editing_tab)
		assert(in_debug_tab and editing_tab ~= dapui.debug_tab.tabpage(), "panes did not open in the debug tab")
		assert(label == "DAP Source", "source window label is " .. vim.inspect(label))
	end)

	check("treesitter textobjects mapped", function()
		vim.cmd("enew | setfiletype lua")
		vim.wait(200)
		if vim.fn.maparg("]m", "n") == "" then
			return "]m not mapped (known: textobjects 'main' ignores the master-style config)"
		end
	end)

	-- Every plugin loads without errors.
	local failed = {}
	for name, plugin in pairs(require("lazy.core.config").plugins) do
		if plugin._.installed and not plugin._.loaded then
			local loaded, load_err = pcall(load, name)
			if not loaded then
				failed[#failed + 1] = name .. " (" .. tostring(load_err):gsub("\n.*", "") .. ")"
			end
		end
	end
	vim.wait(1000)
	table.sort(failed)
	report(#failed == 0 and "PASS" or "FAIL", "every plugin loads", table.concat(failed, "; "))

	check("no deprecated API use", function()
		vim.cmd("silent checkhealth vim.deprecated")
		local found = {}
		for _, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
			local what = line:match("WARNING (.-) is deprecated")
			if what then
				found[#found + 1] = what
			end
		end
		vim.cmd("silent! bwipeout!")
		if #found > 0 then
			return table.concat(found, "; ")
		end
	end)
end, debug.traceback)

if not ok then
	report("FAIL", "check script", tostring(err):gsub("\n.*", ""))
end
finish()
