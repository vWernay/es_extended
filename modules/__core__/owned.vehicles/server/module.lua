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

module.cache                = {}
module.cache.ownedVehicles  = {}

module.reloadOwnedVehicles = function()
	module.cache               = {}
	module.cache.ownedVehicles = {}

  MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function(result)
    if result then
      if  module.cache.ownedVehicles == nil then
        module.cache.ownedVehicles = {}
      end

      for i=1,#result,1 do
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
      end

      print("^2owned vehicles recached^7")
    else
      print("^1error recaching owned vehicles^7")
    end
  end)
end