-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

M('events')
local utils = M("utils")

local resName = GetCurrentResourceName()
local jobs = json.decode(LoadResourceFile(resName, 'modules/__core__/modules.json'))

module.Init = function()
    module.RegisterControls()
end

module.MenuStatus = function(status)
    for i=1, #jobs, 1 do
        local match = jobs[i]

        if string.match(match, "job") then
            local result = {}

            for job in (match.."-"):gmatch("(.-)".."-") do
                table.insert(result, job)
            end

            request("job-menu:getJob", function(player_job)
                if player_job == result[2] then
                    if status then
                        print("Open Menu: " .. player_job)
                        emit(match..":open".. player_job .."menu")
                    else
                        print("Close Menu: " .. player_job)
                        emit(match..":close".. player_job .."menu")
                    end

                    break
                end
            end)
        end
    end
end

module.RegisterControls = function()
    Input.RegisterControl(Input.Groups.MOVE, Input.Controls.SELECT_CHARACTER_FRANKLIN)
end