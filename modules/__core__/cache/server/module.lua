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

module.Cache = {}

module.getCacheByName = function(cacheName)
    if module.Cache[cacheName] then
        return module.Cache[cacheName]
    else
        return nil
    end
end

-- ESX.SetInterval(5000, function()
--   if module.Cache["owned_vehicles"] then
--     if module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1][1].identifier then
--         for k,v in pairs(module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1]) do
--             for l,m in pairs(module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1][k]) do
--                 print(l .. " | " .. tostring(m))
--             end
--         end
--     end
--   end
-- end)

module.UpdateIdentityCache = function(cacheName, identifier, id, updateData)
    if module.Cache[cacheName][identifier][id] then
        table.insert(module.Cache[cacheName][identifier][id], updateData)

        return true
    else
        return false
    end
end

module.UpdateBasicCache = function(cacheName, updateData)
    if module.Cache[cacheName] then
        table.insert(module.Cache[cacheName], updateData)

        return true
    else
        return false
    end
end