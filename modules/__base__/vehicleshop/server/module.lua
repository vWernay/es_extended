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

module.Cache            = {}
module.Cache.categories = {}
module.Cache.vehicles   = {}
module.Cache.usedPlates = {}

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.isPlateTaken = function(plate)
  if module.Cache.usedPlates then
    module.Cache.usedPlates = {}
  end

  module.Cache.usePlates = Cache.getCacheByName("usedPlates")

  for _,value in ipairs(module.Cache.usedPlates) do
    if tostring(value) == tostring(plate) then
      return true
    end
  end

  return false
end

module.excessPlateLength = function(plate, plateUseSpace, plateLetters, plateNumbers)
    local checkedPlate = tostring(plate)
    local plateLength = string.len(checkedPlate)

    if plateLength > 8 then
        print("^1Generated plate is more than 8 characters. FiveM does not support this.^7")
        return true
    else
        return false
    end
end

module.UpdateVehicle = function(vehicleProps, plate, model)
  local player = Player.fromId(source)

  if module.Config.UseCache then
    local value = json.encode(vehicleProps)

    Cache.UpdateValueInIdentityCache("owned_vehicles", player.identifier, player:getIdentityId(), "plate", plate, "vehicle", value)
  else
    MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate AND model = @model', {
      ['@plate']   = plate,
      ['@model']   = model,
      ['@vehicle'] = json.encode(vehicleProps)
    })
  end
end
