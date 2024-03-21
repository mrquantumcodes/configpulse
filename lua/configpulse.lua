-- Initialize an empty table to store file paths
local M = {}

M.file_paths = {}

-- Recursive function to traverse directories
M.traverse_directory = function(directory)
    local items = vim.fn.readdir(directory)
    if not items then
        return
    end

    for _, item in ipairs(items) do
        local path = directory .. '/' .. item
        local is_directory = vim.fn.isdirectory(path) == 1

        if not is_directory then
			if item ~= "lazy-lock.json" then
            	table.insert(M.file_paths, path)
			end
        elseif item ~= '.' and item ~= '..' then
			-- skip git directory
			if item ~= '.git' then
            M.traverse_directory(path)
			end
        end
    end
end

-- Specify the root directory to start traversal

M.find_time = function()
	M.root_directory = vim.fn.stdpath('config')
	M.traverse_directory(M.root_directory)

	local times = {}
	min_time = 0

	-- Print the collected file paths
	for _, path in ipairs(M.file_paths) do
		mod_time = vim.fn.getftime(path)
		

		-- find which file was modified most recently
		if mod_time > min_time then
			min_time = mod_time
		end
	end


	-- convert to human readable time in days, hours, minutes
	min_time = os.time() - min_time
	days = math.floor(min_time / 86400)
	hours = math.floor((min_time % 86400) / 3600)
	minutes = math.floor((min_time % 3600) / 60)

	if days > 0 then
		print(string.format("Last modified %d days, %d hours, %d minutes ago", days, hours, minutes))
	elseif hours > 0 then
		print(string.format("Last modified %d hours, %d minutes ago", hours, minutes))
	else
		print(string.format("Last modified %d minutes ago", minutes))
	end
end


-- set command ConfigPulse lua require('configpulse').find_time()
vim.cmd(
[[command! ConfigPulse lua require"configpulse".find_time() ]])

return M
