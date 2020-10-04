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

local Command = M("events")
local migrate = M('migrate')

on("esx:db:ready", function()
  migrate.Ensure("owned.vehicles", "core")
end)

on("esx:startCache", function()
  MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function(result)
    if result then
      if  module.cache.ownedVehicles == nil then
        module.cache.ownedVehicles = {}
      end

      for i=1,#result,1 do
        if result[i].owner then

          if module.cache.ownedVehicles[result[i].id] == nil then
            module.cache.ownedVehicles[result[i].id] = {}
          end

          if result[i].id then
            print("id: " .. result[i].id)
          end

          if result[i].owner then
            print("owner: " .. result[i].owner)
          end

          if result[i].plate then
            print("plate: " .. result[i].plate)
          end

          if result[i].model then
            print("model: " .. result[i].model)
          end

          if result[i].sell_price then
            print("Sell Price: " .. result[i].sell_price)
          end

          if result[i].vehicle then
            print("Vehicle: " .. tostring(result[i].vehicle))
          end

          if result[i].type then
            print("Type: " .. result[i].type)
          end

          if result[i].stored then
            print("Stored: " .. result[i].stored)
          end

          if result[i].container_id then
            print("container_id: " .. result[i].container_id)
          end

          if result[i].container_id then
            table.insert(module.cache.ownedVehicles, {
              id          = result[i].id,
              owner       = result[i].owner,
              plate       = result[i].plate,
              model       = result[i].model,
              sellPrice   = result[i].sell_price,
              vehicle     = result[i].vehicle,
              type        = result[i].type,
              stored      = result[i].stored,
              containerID = result[i].container_id
            })
          else
            print("Inserting Table")
            table.insert(module.cache.ownedVehicles, {
              id          = result[i].id,
              owner       = result[i].owner,
              plate       = result[i].plate,
              model       = result[i].model,
              sellPrice   = result[i].sell_price,
              vehicle     = result[i].vehicle,
              type        = result[i].type,
              stored      = result[i].stored,
              containerID = nil
            })
          end

          print("Added vehicle")
        end
      end
      print("^2owned vehicles cached^7")
    else
      print("^1error caching owned vehicles^7")
    end
  end)
end)