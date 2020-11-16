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
local Cache    = M("cache")
local utils    = M("utils")

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

onClient('vehicleshop:updateVehicle', function(vehicleProps, plate)
  module.UpdateVehicle(vehicleProps, plate)
end)

onRequest("vehicleshop:checkOwnedVehicle", function(source, cb, plate)
  local player = Player.fromId(source)

  if player then
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
    cb(false)
  end
end)

onRequest("vehicleshop:buyVehicle", function(source, cb, model, plate, price, formattedPrice, vehicleName, name, resellPrice)
  local player = Player.fromId(source)
  local playerData = player:getIdentity()
  if player then
    local data = {
      identifier   = player.identifier,
      id           = player:getIdentityId(),
      plate        = plate,
      model        = model,
      sell_price   = resellPrice,
      sold         = 0,
      stored       = 0,
      vehicle      = json.encode({model = GetHashKey(model), plate = plate}),
      container_id = nil
    }

    if Cache.InsertIntoIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), data) then

      Cache.InsertIntoBasicCache("usedPlates", plate)

      print(_U('vehicleshop:server_buy_success', player:getIdentityId(), playerData:getFirstName(), playerData:getLastName(), name, plate, tostring(formattedPrice)))

      utils.game.createVehicle(model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
        while not DoesEntityExist(vehicle) do
          Wait(10)
        end

        local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

        SetVehicleNumberPlateText(vehicle, plate)
        cb(vehicleID)
      end)
    else
      print(_U('vehicleshop:server_buy_failure'))
    end
  else
    cb(false)
  end
end)

onRequest("vehicleshop:startTestDrive", function(source, cb, model)
  if model and type(model) == 'string' then
    utils.game.createVehicle(model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
      while not DoesEntityExist(vehicle) do
        Wait(10)
      end

      local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

      cb(vehicleID)
    end)
  else
    cb(false)
  end
end)

onRequest("vehicleshop:sellVehicle", function(source, cb, plate, name, resellPrice, formattedPrice)
  local player = Player.fromId(source)
  local playerData = player:getIdentity()

  if player then
    local vehicleCheck = Cache.RetrieveEntryFromIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate)

    if vehicleCheck then
      if Cache.UpdateValueInIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate, "sold", 1) then
        print(_U('vehicleshop:server_sell_success', player:getIdentityId(), playerData:getFirstName(), playerData:getLastName(), name, plate, module.GroupDigits(resellPrice)))
        cb(true)
      else
        print(_U('vehicleshop:server_sell_failure'))
        cb(false)
      end
    else
      print(_U('vehicleshop:server_sell_failure'))
      cb(false)
    end
  else
    cb(false)
  end
end)

onRequest("vehicleshop:isPlateTaken", function(source, cb, plate, plateUseSpace, plateLetters, plateNumbers)
  if module.isPlateTaken(plate) then
    cb(true)
  else
    if module.excessPlateLength(plate, plateUseSpace, plateLetters, plateNumbers) then
      cb(true)
    else
      cb(false)
    end
  end
end)

onRequest("vehicleshop:getCategories", function(source, cb)
  module.Cache.categories = Cache.getCacheByName("categories")

  if module.Cache.categories then
    cb(module.Cache.categories)
  else
    cb(nil)
  end
end)

onRequest("vehicleshop:getVehicles", function(source, cb)
  module.Cache.vehicles = Cache.getCacheByName("vehicles")

  if module.Cache.vehicles then
    cb(module.Cache.vehicles)
  else
    cb(nil)
  end
end)
