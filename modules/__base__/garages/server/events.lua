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

local Command  = M("events")
local ownedVehicles = M("owned.vehicles")
local utils    = M("utils")

on("esx:saveCache", function()
  print("^1owned.vehicles cache saving...^7")
  -- Placeholder
  print("^2owned.vehicles save complete.^7")
end)

onClient('garages:updateVehicle', function(plate, vehicleProps)
  MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
    ['@vehicle'] = json.encode(vehicleProps),
    ['@plate']   = plate,
  })
end)

onClient('garages:storeVehicle', function(plate)
  MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
    ['@stored'] = 1,
    ['@plate']  = plate,
  })
end)

onRequest('garages:checkOwnedVehicle', function(source, cb, plate)
  local player = Player.fromId(source)

  if player then
    MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate AND id = @identityId AND identifier = @identifier', {
      ['@plate']      = plate,
      ['@identityId'] = player:getIdentityId(),
      ['@identifier'] = player.identifier
    }, function(result)
      if result then
        if result[1] then
          cb(true)
        else
          cb(false)
        end
      else
        cb(false)
      end
    end)
  else
    cb(false)
  end
end)

onRequest('garages:removeVehicleFromGarage', function(source, cb, plate)
  MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
    ['@stored'] = 0,
    ['@plate']  = plate
  }, function(rowsChanged)
    cb(true)
  end)
end)

onRequest('garages:getOwnedVehiclesFromCache', function(source, cb)
  local player = Player.fromId(source)

  local playerVehicles = ownedVehicles.getOwnedVehicles()

  local vehicles = {}

  if playerVehiclesehicles[player.identifier] then
    for k,v in pairs(playerVehiclesehicles[player.identifier]) do
      if v.identifier == player.identifier and v.id == player:getIdentityId() then
        table.insert(vehicles, {
          vehicleProps = json.decode(v.vehicle),
          stored       = v.stored,
          model        = v.model,
          plate        = v.plate
        })
      end
    end
  end

  cb(vehicles)
end)

onRequest("garages:storeAllVehicles", function(source, cb, plate)
  MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored', {
    ['@stored'] = 1,
  }, function(rowsChanged)
    print("^2returned all owned vehicles to their garages^7")
    cb(true)
  end)
end)
