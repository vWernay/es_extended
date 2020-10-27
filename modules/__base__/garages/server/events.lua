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
local Cache   = M("cache")
local utils   = M("utils")

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

onClient('garages:updateVehicle', function(vehicleProps, plate)
  module.UpdateVehicle(vehicleProps, plate)
end)

onRequest('garages:storeVehicle', function(source, cb, plate)
  local player = Player.fromId(source)

  if module.Config.UseCache then
    local vehicleCheck = Cache.RetrieveEntryFromIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate)

    if vehicleCheck then
      if Cache.UpdateValueInIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate, "stored", 1) then
        cb(true)
      else
        cb(false)
      end
    else
      cb(false)
    end
  else
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
      ['@stored'] = 1,
      ['@plate']  = plate,
    })
  end
end)

onRequest('garages:checkOwnedVehicle', function(source, cb, plate)
  local player = Player.fromId(source)

  if player then
    if module.Config.UseCache then
      local vehicleCheck = Cache.RetrieveEntryFromIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate)

      if vehicleCheck then
        if vehicleCheck.model and vehicleCheck.sell_price then
          local vehicleData = {
            model = vehicleCheck.model,
            resellPrice = vehicleCheck.sell_price
          }

          cb(vehicleData)
        else
          cb(false)
        end
      else
        cb(false)
      end
    else
      MySQL.Async.fetchAll('SELECT model, sell_price FROM owned_vehicles WHERE plate = @plate AND id = @identityId AND identifier = @identifier', {
        ['@plate']      = plate,
        ['@identityId'] = player:getIdentityId(),
        ['@identifier'] = player.identifier
      }, function(result)
        if result then
          if result[1] then
            local vehicleData = {
              model       = result[1].model,
              resellPrice = result[1].sell_price
            }

            cb(vehicleData)
          else
            cb(false)
          end
        else
          cb(false)
        end
      end)
    end
  else
    cb(false)
  end
end)

onRequest('garages:removeVehicleFromGarage', function(source, cb, plate)
  local player = Player.fromId(source)

  if module.Config.UseCache then
    local vehicleCheck = Cache.RetrieveEntryFromIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate)

    if vehicleCheck then
      if Cache.UpdateValueInIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate, "stored", 0) then
        cb(true)
      else
        cb(false)
      end
    else
      cb(false)
    end
  else
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
      ['@stored'] = 0,
      ['@plate']  = plate
    }, function(rowsChanged)
      cb(true)
    end)
  end
end)

onRequest('garages:getOwnedVehicles', function(source, cb)
  local player = Player.fromId(source)

  if module.Config.UseCache then
    module.Cache.ownedVehicles = Cache.getCacheByName("owned_vehicles")

    if module.Cache.ownedVehicles then
      if module.Cache.ownedVehicles[player.identifier] then
        if module.Cache.ownedVehicles[player.identifier][player:getIdentityId()] then
          cb(module.Cache.ownedVehicles[player.identifier][player:getIdentityId()])
        else
          cb(nil)
        end
      else
        cb(nil)
      end
    else
      cb(nil)
    end
  else

  end
end)

onRequest("garages:storeAllVehicles", function(source, cb, plate)
  if module.Config.UseCache then
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored', {
      ['@stored'] = 1,
    }, function(rowsChanged)
      print("^2returned all owned vehicles to their garages^7")
      cb(true)
    end)
  else
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored', {
      ['@stored'] = 1,
    }, function(rowsChanged)
      print("^2returned all owned vehicles to their garages^7")
      cb(true)
    end)
  end
end)
