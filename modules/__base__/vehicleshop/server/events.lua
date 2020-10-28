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

onRequest("vehicleshop:buyVehicle", function(source, cb, model, plate, price, formattedPrice, vehicleName, name, resellPrice)
  local player = Player.fromId(source)
  local playerData = player:getIdentity()
  if player then
    if module.Config.UseCache then
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

        print("^7[^4" .. player:getIdentityId() .. "^7 |^5 " .. playerData:getFirstName() .. " " .. playerData:getLastName() .. "^7] ^3bought^7: ^5" .. name .. "^7 with the plates ^3" .. plate .. " ^7for ^2$" .. tostring(formattedPrice) .. "^7")

        utils.game.createVehicle(model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
          while not DoesEntityExist(vehicle) do
            Wait(10)
          end

          local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

          SetVehicleNumberPlateText(vehicle, plate)
          cb(vehicleID)
        end)
      else
        print("^1Error purchasing vehicle. Please contact the server administrator.^7")
      end
    else
      MySQL.Async.execute('INSERT INTO owned_vehicles (identifier, id, plate, model, sell_price, vehicle) VALUES (@identifier, @identityId, @plate, @model, @sell_price, @vehicle)', {
        ['@identifier'] = player.identifier,
        ['@identityId'] = player:getIdentityId(),
        ['@plate']      = plate,
        ['@model']      = model,
        ['@sell_price'] = resellPrice,
        ['@vehicle']    = json.encode({model = GetHashKey(model), plate = plate}),
      }, function(rowsChanged)

        print("^7[^4" .. player:getIdentityId() .. "^7/^5" .. playerData:getFirstName() .. " " .. playerData:getLastName() .. "^7] ^3bought^7: ^5" .. name .. "^7 with the plates ^3" .. plate .. " ^7for ^2$" .. tostring(formattedPrice) .. "^7")

        utils.game.createVehicle(model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
          while not DoesEntityExist(vehicle) do
            Wait(10)
          end

          local vehicleID = NetworkGetNetworkIdFromEntity(vehicle)

          SetVehicleNumberPlateText(vehicle, plate)
          cb(vehicleID)
        end)
      end)
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

  if module.Config.UseCache then
    local vehicleCheck = Cache.RetrieveEntryFromIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate)

    if vehicleCheck then
      if Cache.UpdateValueInIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate, "sold", 1) then
        cb(true)
      else
        cb(false)
      end
    else
      cb(false)
    end
  else
    MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate AND id = @identityId AND identifier = @identifier', {
      ['@plate']      = plate,
      ['@identityId'] = player:getIdentityId(),
      ['@identifier'] = player.identifier
    }, function(result)
      if result then
        if result[1] then
          MySQL.Async.execute('UPDATE owned_vehicles SET sold = @sold WHERE plate = @plate', {
            ['@plate'] = plate,
            ['@sold']  = 1
          })

          cb(true)
        else
          cb(false)
        end
      else
        cb(false)
      end
    end)
  end
end)

onRequest("vehicleshop:isPlateTaken", function(source, cb, plate, plateUseSpace, plateLetters, plateNumbers)
  if module.Config.UseCache then
    if module.isPlateTaken(plate) then
      cb(true)
    else
      if module.excessPlateLength(plate, plateUseSpace, plateLetters, plateNumbers) then
        cb(true)
      else
        cb(false)
      end
    end
  else
    MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
      ['@plate'] = plate
    }, function(result)

      if result[1] then
        cb(true)
      else
        if module.excessPlateLength(plate, plateUseSpace, plateLetters, plateNumbers) then
          cb(true)
        else
          cb(false)
        end
      end
    end)
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


onRequest("vehicleshop:getVehiclesAndCategories", function(source, cb)
  MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
    if result then
      for i=1,#result,1 do

        if  module.Cache.vehicles == nil then
          module.Cache.vehicles = {}
        end

        if  module.Cache.categories == nil then
          module.Cache.categories = {}
        end

        table.insert(module.Cache.vehicles, {
          name          = result[i].name,
          model         = result[i].model,
          price         = result[i].price,
          category      = result[i].category,
          categoryLabel = result[i].category_label
        })
      end

      for k,v in pairs(module.Cache.vehicles) do
        if #module.Cache.categories > 0 then
          for i,j in pairs(module.Cache.categories) do
            if v.category == j.category then
              module.categoryAlreadyExists = true
            end
          end

          if module.categoryAlreadyExists then
            module.categoryAlreadyExists = false
          else
            table.insert(module.Cache.categories, {
              category      = v.category,
              categoryLabel = v.categoryLabel
            })
          end
        else
          table.insert(module.Cache.categories, {
            category      = v.category,
            categoryLabel = v.categoryLabel
          })
        end
      end
    end

    if module.Cache.vehicles and module.Cache.categories then
      cb(module.Cache)
    else
      cb(nil)
    end
  end)
end)