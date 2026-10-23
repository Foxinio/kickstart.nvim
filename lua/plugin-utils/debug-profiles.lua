local M = {}
local directory = vim.fn.stdpath('data') .. '/verilator-debug/profiles'
local selected_path = directory .. '/../selected'
local selected, current
local snapshots = {}

local function path(name)
	assert(type(name) == 'string' and name:match('^[%w_-]+$'), 'Profile names use letters, numbers, _ and -')
	return directory .. '/' .. name .. '.json'
end

local function read(filename)
	return table.concat(vim.fn.readfile(filename), '\n')
end

function M.validate(profile)
	assert(type(profile) == 'table', 'Profile must be an object')
	assert(type(profile.program) == 'string' and profile.program ~= '', 'Profile needs a program')
	assert(not profile.program:find('\0', 1, true), 'Program contains NUL')
	for _, key in ipairs({ 'root', 'cwd' }) do
		assert(profile[key] == nil or type(profile[key]) == 'string', key .. ' must be a path')
	end
	for _, key in ipairs({ 'args', 'extra_args', 'simulation_args', 'regress_args', 'setup_commands' }) do
		local values = profile[key] or {}
		assert(type(values) == 'table' and vim.islist(values), key .. ' must be an array')
		for _, value in ipairs(values) do
			assert(type(value) == 'string' and not value:find('\0', 1, true), key .. ' must contain strings without NUL')
		end
	end
	assert(profile.environment == nil or type(profile.environment) == 'table', 'environment must be an object')
	for key, value in pairs(profile.environment or {}) do
		assert(type(key) == 'string' and key ~= '' and not key:find('=', 1, true) and not key:find('\0', 1, true) and type(value) == 'string'
			and not value:find('\0', 1, true), 'Invalid environment entry')
	end
	if profile.replay ~= nil then
		assert(type(profile.replay) == 'table' and profile.replay.replay == nil, 'Invalid replay')
		M.validate(profile.replay)
		assert(type(profile.replay.cwd) == 'string' and type(profile.replay.simulation) == 'boolean', 'Invalid replay context')
	end
	return profile
end

local function absolute(filename, base)
	filename = vim.fn.expand(filename)
	return vim.fs.normalize(filename:sub(1, 1) == '/' and filename or base .. '/' .. filename)
end

function M.resolve(profile)
	M.validate(profile)
	local program = absolute(profile.program, directory)
	assert(vim.fn.executable(program) == 1, 'Executable not found: ' .. program)
	local root
	if profile.root and profile.root ~= '' then
		root = absolute(profile.root, vim.fs.dirname(program))
	else
		for _, candidate in ipairs({ program, vim.uv.fs_realpath(program) or program }) do
			local dir = vim.fs.dirname(candidate)
			while dir do
				if vim.fn.filereadable(dir .. '/bin/verilator') == 1 and vim.fn.filereadable(dir .. '/include/verilated.h') == 1 then
					root = dir
					break
				end
				local parent = vim.fs.dirname(dir)
				dir = parent ~= dir and parent or nil
			end
			if root then break end
		end
	end
	assert(root and vim.fn.isdirectory(root) == 1, 'Cannot infer VERILATOR_ROOT; set root in the profile')
	return program, root, absolute(profile.cwd or '.', root)
end

function M.pick(title, items, callback, filenames)
	assert(#items > 0, 'Nothing to select: ' .. title)
	local actions = require('telescope.actions')
	local state = require('telescope.actions.state')
	local config = require('telescope.config').values
	require('telescope.pickers').new({}, {
		prompt_title = title,
		finder = require('telescope.finders').new_table({
			results = items,
			entry_maker = function(item)
				return { value = item, display = item, ordinal = item, filename = filenames and filenames(item) or nil }
			end,
		}),
		sorter = config.generic_sorter({}),
		previewer = filenames and config.file_previewer({}) or nil,
		attach_mappings = function(buf)
			actions.select_default:replace(function()
				local entry = state.get_selected_entry()
				actions.close(buf)
				if entry then
					vim.schedule(function()
						local ok, err = pcall(callback, entry.value)
						if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
					end)
				end
			end)
			return true
		end,
	}):find()
end

function M.names()
	return vim.tbl_map(function(filename) return vim.fn.fnamemodify(filename, ':t:r') end,
		vim.fn.globpath(directory, '*.json', false, true))
end

function M.load(name)
	local filename = path(name)
	local contents = read(filename)
	local profile = M.validate(vim.json.decode(contents))
	selected, current, snapshots[name] = name, profile, contents
	vim.fn.writefile({ name }, selected_path)
	return profile
end

function M.get()
	return current, selected
end

function M.save(name, force)
	assert(current, 'Load a profile first')
	M.validate(current)
	local filename = path(name)
	if vim.fn.filereadable(filename) == 1 and not force then
		assert(snapshots[name] and snapshots[name] == read(filename), 'Profile changed on disk; load it again or use save!')
	end
	local encoded = vim.json.encode(current)
	local temporary = filename .. '.tmp'
	vim.fn.writefile({ encoded }, temporary)
	assert(vim.uv.fs_chmod(temporary, 384))
	assert(vim.uv.fs_rename(temporary, filename))
	M.load(name)
end

function M.choose(name, callback)
	if name and name ~= '' then callback(name) else M.pick('Debug profiles', M.names(), callback, path) end
end

function M.with_current(callback)
	if current then callback(current) else M.choose(nil, function(name) callback(M.load(name)) end) end
end

function M.command(opts)
	local action, name = opts.fargs[1], opts.fargs[2]
	if not action then
		return M.pick('Profile action', { 'load', 'edit', 'save', 'clone', 'delete' }, function(choice)
			M.command({ fargs = { choice }, bang = false })
		end)
	end
	assert(vim.tbl_contains({ 'load', 'edit', 'save', 'clone', 'delete' }, action), 'Unknown profile action: ' .. action)
	if action == 'clone' and name then
		M.with_current(function()
			assert(vim.fn.filereadable(path(name)) == 0, 'Profile already exists: ' .. name)
			M.save(name)
		end)
		return
	end
	M.choose(name, function(choice)
		if action == 'load' then
			M.load(choice)
		elseif action == 'edit' then
			vim.cmd.edit(vim.fn.fnameescape(path(choice)))
		elseif action == 'save' then
			M.save(choice, opts.bang)
		elseif action == 'delete' then
			assert(vim.fn.delete(path(choice)) == 0, 'Could not delete profile')
			if selected == choice then selected, current = nil, nil; vim.fn.delete(selected_path) end
		else
			M.load(choice)
			vim.ui.input({ prompt = 'Clone profile as: ' }, function(new_name)
				if new_name and new_name ~= '' then
					local ok, err = pcall(M.command, { fargs = { 'clone', new_name } })
					if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
				end
			end)
		end
	end)
end

function M.setup()
	vim.fn.mkdir(directory, 'p', 448)
	if #M.names() == 0 then
		local seed = vim.fn.stdpath('config') .. '/scripts/debug/verilator.json'
		vim.fn.writefile(vim.fn.readfile(seed), path('verilator'))
	end
	if vim.fn.filereadable(selected_path) == 1 then
		local ok, err = pcall(M.load, read(selected_path))
		if not ok then vim.notify('Could not restore debug profile: ' .. tostring(err), vim.log.levels.WARN) end
	end
end

return M
