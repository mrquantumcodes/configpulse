local M = {}

function M.get_days_since_last_edit(path)
    local fs_stat = vim.loop.fs_stat
    local current_time = os.time()

    local function traverse_directory(dir_path)
        local lowest_days = math.huge

        for entry in vim.fn.readdir(dir_path) do
            local entry_path = dir_path .. '/' .. entry

            local stat = fs_stat(entry_path)
            if stat and stat.type == 'directory' then
                if entry ~= '.' and entry ~= '..' then
                    lowest_days = math.min(lowest_days, traverse_directory(entry_path))
                end
            elseif stat and stat.type == 'file' then
                local days_since_edit = (current_time - stat.mtime.sec) / (24 * 60 * 60)
                lowest_days = math.min(lowest_days, days_since_edit)
            end
        end

        return lowest_days
    end

    return traverse_directory(path)
end

function M.display_days_since_last_edit()
    local config_path = vim.fn.stdpath('config')
    local days_since_last_edit = M.get_days_since_last_edit(config_path)

    vim.api.nvim_out_write('You haven\'t touched your config in ' .. math.floor(days_since_last_edit) .. ' days.\n')
end

vim.cmd([[command! ConfigPulse lua require('configpulse').display_days_since_last_edit()]])
