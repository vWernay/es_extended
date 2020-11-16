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

local Cache = M("cache")

module.Cache = {}
module.Cache.Statuses, module.Cache.StatusReady, module.Ready = {}, {}, false

module.CreateStatus = function(identifier, identityId, name, color, iconType, icon, val, fadeType)
    if not module.Cache.Statuses[identifier] then
        module.Cache.Statuses[identifier] = {}
    end

    if not module.Cache.Statuses[identifier][identityId] then
        module.Cache.Statuses[identifier][identityId] = {}
    end

    if not module.Cache.Statuses[identifier][identityId][name] then
        module.Cache.Statuses[identifier][identityId][name] = {}
    end

    module.Cache.Statuses[identifier][identityId][name]["id"] = name
    module.Cache.Statuses[identifier][identityId][name]["color"] = color
    module.Cache.Statuses[identifier][identityId][name]["value"] = val
    module.Cache.Statuses[identifier][identityId][name]["icon"] = icon
    module.Cache.Statuses[identifier][identityId][name]["iconType"] = iconType
    module.Cache.Statuses[identifier][identityId][name]["fadeType"] = fadeType
end

module.StatusesCreated = function()
    for _, playerId in ipairs(GetPlayers()) do
        local player = Player.fromId(playerId)
        local identifier = player.identifier
        local id = player:getIdentityId()

        if not module.Cache.StatusReady[identifier] then
            module.Cache.StatusReady[identifier] = {}
        end

        if not module.Cache.StatusReady[identifier][id] then
            module.Cache.StatusReady[identifier][id] = true
        end

        if module.Cache.Statuses[identifier][id] and module.Cache.StatusReady[identifier][id] then
           Cache.UpdateTableInIdentityCache("identities", player.identifier, player:getIdentityId(), Config.Modules.Status.StatusIndex, "status", "value", module.Cache.Statuses[identifier][id])
           emitClient('esx:status:updateStatus', player.source, module.Cache.Statuses[identifier][id])
        end
    end
end

module.UpdateStatus = function()
    for _, playerId in ipairs(GetPlayers()) do
        local player           = Player.fromId(playerId)
        local identifier       = player.identifier
        local id               = player:getIdentityId()
        local existingStatuses = {}
        local status           = {}
        module.StatusLow       = false
        module.StatusDying     = false
        module.StatusDrunk     = 0
        module.StatusDrugs     = 0
        module.StatusStress    = 0

        if module.Cache.StatusReady[identifier][id] then
            for k,v in pairs(Config.Modules.Status.StatusIndex) do
                if module.Cache.Statuses[identifier][id][v]["fadeType"] == "desc" then
                    if module.Cache.Statuses[identifier][id][v]["value"] > 0 and module.Cache.Statuses[identifier][id][v]["value"] <= 10 then
                        module.StatusLow   = true
                    elseif module.Cache.Statuses[identifier][id][v]["value"] == 0 then
                        module.StatusLow   = true
                        module.StatusDying = true
                    end

                    if module.Cache.Statuses[identifier][id][v]["value"] > 0 then
                        module.Cache.Statuses[identifier][id][v]["value"] = module.Cache.Statuses[identifier][id][v]["value"] - 1
                        table.insert(status, {k = module.Cache.Statuses[identifier][id][v]["value"]})
                    end
                elseif module.Cache.Statuses[identifier][id][v]["fadeType"] == "asc" then
                    if module.Cache.Statuses[identifier][id][v]["value"] >= 100 then
                        module.StatusDying = true
                    end

                    if module.Cache.Statuses[identifier][id][v]["value"] > 0 then
                        module.Cache.Statuses[identifier][id][v]["value"] = module.Cache.Statuses[identifier][id][v]["value"] - 1
                        if module.Cache.Statuses[identifier][id][v]["id"] == "drunk" then
                            module.StatusDrunk = module.Cache.Statuses[identifier][id][v]["value"]
                        elseif module.Cache.Statuses[identifier][id][v]["id"] == "drugs" then
                            module.StatusDrugs = module.Cache.Statuses[identifier][id][v]["value"]
                        elseif module.Cache.Statuses[identifier][id][v]["id"] == "stress" then
                            module.StatusStress = module.Cache.Statuses[identifier][id][v]["value"]
                        end
                        table.insert(status, {k = module.Cache.Statuses[identifier][id][v]["value"]})
                    end
                end
            end

            Cache.UpdateTableInIdentityCache("identities", player.identifier, player:getIdentityId(), Config.Modules.Status.StatusIndex, "status", "value", module.Cache.Statuses[identifier][id])
            emitClient('esx:status:updateStatus', player.source, module.Cache.Statuses[identifier][id])
            emitClient('esx:status:statCheck', player.source, module.StatusLow, module.StatusDying, module.StatusDrunk, module.StatusDrugs, module.StatusStress)
        end
    end
end

module.SetStatus = function(statusName, value)
    local player           = Player.fromId(source)
    local identifier       = player.identifier
    local id               = player:getIdentityId()
    local status           = {}
    module.StatusDying     = false
    module.StatusLow       = false
    module.StatusDrunk     = 0
    module.StatusDrugs     = 0
    module.StatusStress    = 0

    if module.Cache.StatusReady[identifier][id] then
        for k,v in pairs(Config.Modules.Status.StatusIndex) do
            if tostring(v) == tostring(statusName) then
                if module.Cache.Statuses[identifier][id][v]["fadeType"] == "asc" then
                    if value > 0 then
                        if tostring(statusName) == "drunk" then
                          module.StatusDrunk = module.Cache.Statuses[identifier][id][v]["value"]
                        elseif tostring(statusName) == "drugs" then
                            module.StatusDrugs = module.Cache.Statuses[identifier][id][v]["value"]
                        elseif tostring(statusName) == "stress" then
                            module.StatusStress = module.Cache.Statuses[identifier][id][v]["value"]
                        end
                    end
                end
                
                module.Cache.Statuses[identifier][id][v]["value"] = value
                table.insert(status, {k = module.Cache.Statuses[identifier][id][v]["value"]})
            else
                table.insert(status, {k = module.Cache.Statuses[identifier][id][v]["value"]})
            end
        end

        Cache.UpdateTableInIdentityCache("identities", player.identifier, player:getIdentityId(), Config.Modules.Status.StatusIndex, "status", "value", module.Cache.Statuses[identifier][id])
        emitClient('esx:status:updateStatus', player.source, module.Cache.Statuses[identifier][id])
        emitClient('esx:status:statCheck', player.source, module.StatusLow, module.StatusDying, module.StatusDrunk, module.StatusDrugs, module.StatusStress)
    end
end