-------------------------------------------------------------------------------
-- run latexmk on write to tex source file

local extension_enabled = false

-- Usercmd to turn on this extension
vim.api.nvim_create_user_command("MakeOnSaveEnable", function()
	extension_enabled = true
	vim.api.nvim_echo({ { "MakeOnSave on" } }, false, {})
end, {})

vim.api.nvim_create_user_command("MakeOnSaveDisable", function()
	extension_enabled = false
	vim.api.nvim_echo({ { "MakeOnSave off" } }, false, {})
end, {})

-- Function to check if a file exists
local function file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

local function run_command(command, callback)
	local handle = io.popen(command .. " &> /dev/null; echo -n $?")
	if type(handle) == "userdata" then
		local output = handle:read("*a")
		print(tostring(output))
		handle:close()
		local exit_code = output:match("(%d+)$")
		callback({ output, exit_code })
	end
end


vim.api.nvim_create_autocmd({ "BufAdd" }, {
	pattern = { "*.tex", "*.sty" },
	desc = "Add events to run `!make tex` everytime this buffer is writen",
	callback = function(tbl)
		local file = tbl.file
		if file:match("%.tex") then
			local pdf_file = file:gsub("%.tex$", ".pdf")
			if file_exists(pdf_file) then
				vim.api.nvim_echo({ { "`xdg-open " .. pdf_file .. "` run" } }, false, {})
				os.execute("xdg-open " .. pdf_file)
			else
				vim.api.nvim_echo({ { pdf_file .. " not found" } }, false, {})
			end
		end

		-- TODO: instead of running `make tex`,
		-- make it run latexmk with apropriate arguments
		local id = vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			buffer = tbl.buf,
			desc = "Call `make tex` on write",
			-- command = "!make tex",
			callback = function()
				if extension_enabled then
					run_command("make tex", function(opts)
						vim.api.nvim_echo({
								{ "`make tex` executed, with result: " .. tostring(opts.output) } },
							false, {})
					end)
				end
			end,
		})
		vim.api.nvim_create_autocmd({ "BufDelete" }, {
			buffer = tbl.buf,
			desc = "Delete autocmd that calls `make tex` on write",
			callback = function()
				vim.api.nvim_del_autocmd(id)
			end,
		})
	end,
})
