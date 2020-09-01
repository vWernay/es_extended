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
M('serializable')
M('cache')
M('ui.menu')

local Interact = M('interact')
local utils    = M("utils")
local camera   = M("camera")

module.Config  = run('data/config.lua', {vector3 = vector3})['Config']

module.isInGarageMenu    = false
module.inMarker          = false
module.CurrentAction     = nil
module.CurrentActionData = nil
module.spawnedVehicle    = nil
module.savedPosition     = nil
module.vehicleLoaded     = false

-----------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------

module.Init = function()
  Citizen.CreateThread(function()
    for k,v in pairs(module.Config.GarageEntrances) do
      local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

      SetBlipSprite (blip, 357)
      SetBlipDisplay(blip, 4)
      SetBlipScale  (blip, 0.75)
      SetBlipColour (blip, 3)
      SetBlipAsShortRange(blip, true)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Garage")
      EndTextCommandSetBlipName(blip)
    end
  end)

  request("garages:storeAllVehicles", function(result)
    print("Returned all owned vehicles to their garages.")
  end)

  for k, v in pairs(module.Config.GarageEntrances) do

    local key = 'garages:entrance:' .. tostring(k)

    Interact.Register({
      name         = key,
      location     = tostring(k),
      type         = 'marker',
      distance     = module.Config.DrawDistance,
      radius       = 2.0,
      pos          = v.Pos,
      size         = v.Size,
      mtype        = v.Type,
      color        = v.Color,
      rotate       = true,
      bobUpAndDown = false,
      faceCamera   = true,
      groundMarker = true
    })

    on('esx:interact:enter:' .. key, function(data)
      if data.name == key then
        module.CurrentActionData = { 
          Location = data.location,
          Pos      = module.Config.GarageEntrances[data.location].Pos
        }

        Interact.ShowHelpNotification("Press ~INPUT_CONTEXT~ to get a vehicle from your garage.")

        module.CurrentAction = function()
          module.OpenGarageMenu(module.CurrentActionData)
        end

        if not module.inMarker then
          module.inMarker = true
        end
      end
    end)

    on('esx:interact:exit:' .. key, function(data) 
      module.Exit()
    end)
  end

  for k, v in pairs(module.Config.GarageReturns) do

    local key = 'garages:return:' .. tostring(k)

    Interact.Register({
      name         = key,
      location     = tostring(k),
      type         = 'marker',
      distance     = module.Config.DrawDistance,
      radius       = 2.0,
      pos          = v.Pos,
      size         = v.Size,
      mtype        = v.Type,
      color        = v.Color,
      rotate       = true,
      bobUpAndDown = false,
      faceCamera   = true,
      groundMarker = true
    })

    on('esx:interact:enter:' .. key, function(data)
      if data.name == key then
        local ped = PlayerPedId()

        if IsPedSittingInAnyVehicle(ped) then
          local vehicle = GetVehiclePedIsIn(ped, false)

          if GetPedInVehicleSeat(vehicle, -1) == ped then

            Interact.ShowHelpNotification("Press ~INPUT_CONTEXT~ to store this vehicle in the garage.")

            module.CurrentActionData = { 
              Location = data.location,
              Pos      = module.Config.GarageReturns[data.location].Pos
            }

            module.CurrentAction = function()
              module.StoreVehicle(module.CurrentActionData)
            end

            if not module.inMarker then
              module.inMarker = true
            end
          end
        else
          Interact.ShowHelpNotification("~r~You must be in a vehicle to use this.")
        end
      end
    end)

    on('esx:interact:exit:' .. key, function(data) 
      module.Exit()
    end)
  end
end

-----------------------------------------------------------------------------------
-- MENU FUNCTIONS
-----------------------------------------------------------------------------------

module.OpenGarageMenu = function(data)

  module.savedPosition = data.Pos

  DoScreenFadeOut(250)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  module.StartGarageRestriction()
  module.EnterGarage(data)

  module.isInGarageMenu = true

  local items = {}

  request('garages:getOwnedVehicles', function(vehicles)
    if vehicles then
      for i=1, #vehicles, 1 do
        if vehicles[i].stored == 1 then
          local name  = GetDisplayNameFromVehicleModel(vehicles[i].vehicleProps.model)
          local plate = utils.math.Trim(vehicles[i].vehicleProps.plate)
          local model = vehicles[i].vehicleProps.model

          local vehicleData = {
            name         = name,
            vehicleProps = vehicles[i].vehicleProps,
            plate        = plate,
            model        = model
          }

          items[#items + 1] = {type = 'button', name = model, label = name .. " [" .. plate .. "]", value = vehicleData}
        elseif vehicles[i].stored == 0 then
          local name  = GetDisplayNameFromVehicleModel(vehicles[i].vehicleProps.model)
          local plate = utils.math.Trim(vehicles[i].vehicleProps.plate)

          local vehicleData = {
            name  = name,
            plate = plate
          }

          items[#items + 1] = {type = 'button', name = 'not_in_garage', label = name .. " - [NOT IN GARAGE]", value = vehicleData}
        end
      end

      items[#items + 1] = {name = 'exit', label = '>> Exit <<', type = 'button'}

      module.garageMenu = Menu('garages.garage', {
        title = "Garage",
        float = 'top|left', -- not needed, default value
        items = items
      })

      module.currentMenu = module.garageMenu

      module.garageMenu:on('item.click', function(item, index)
        if item.name == 'exit' then
          module.DeleteDisplayVehicleInsideGarage()
          module.DestroyGarageMenu()
          DoScreenFadeOut(1000)

          while not IsScreenFadedOut() do
            Citizen.Wait(0)
          end

          module.ExitGarage()
          module.ReturnPlayer(module.savedPosition)
          camera.destroy()
        elseif item.name == 'not_in_garage' then
          utils.ui.showNotification("Your " .. item.value.name .. " with the plates " .. item.value.plate .. " is not in the garage.")
        else
          module.commit(item.value, data)
        end
      end)
    end
  end)

  Citizen.Wait(500)

  camera.setPolarAzimuthAngle(220.0, 120.0)
  camera.setRadius(3.5)
  emit('esx:identity:preventSaving', true)

  DoScreenFadeIn(250)
end

module.OpenRetrievalMenu = function(vehicleData, data)
  local items = {}

  items[#items + 1] = {name = 'yes', label = '>> Yes <<', type = 'button', value = vehicle}
  items[#items + 1] = {name = 'no', label = '>> No <<', type = 'button'}

  if module.garageMenu.visible then
    module.garageMenu:hide()
  end

  module.retrievalMenu = Menu('garages.retrieval', {
    title = "Retrieve " .. vehicleData.name .. " from the garage?",
    float = 'top|left', -- not needed, default value
    items = items
  })

  module.currentMenu = module.retrievalMenu

  module.retrievalMenu:on('destroy', function()
    module.garageMenu:show()
  end)

  module.retrievalMenu:on('item.click', function(item, index)
    if item.name == 'no' then
      module.DeleteDisplayVehicleInsideGarage()
      module.currentDisplayVehicle = nil

      module.retrievalMenu:destroy()

      module.currentMenu = module.garageMenu

      module.garageMenu:focus()
    elseif item.name == 'yes' then

      module.retrievalMenu:hide()

      request("garages:removeVehicleFromGarage", function(success)
        if success then

          local ped = PlayerPedId()

          module.ExitGarageWithSelectedVehicle()

          while not IsScreenFadedOut() do
            Citizen.Wait(0)
          end

          FreezeEntityPosition(ped, false)

          SetEntityCoords(ped, module.Config.GarageSpawns[data.Location].Pos)

          Citizen.Wait(100)

          utils.game.createVehicle(vehicleData.vehicleProps.model, module.Config.GarageSpawns[data.Location].Pos, module.Config.GarageSpawns[data.Location].Heading, function(vehicle)
            local ped = PlayerPedId()
            SetEntityVisible(ped, true)
            TaskWarpPedIntoVehicle(ped, vehicle, -1)

            utils.game.setVehicleProperties(vehicle, vehicleData.vehicleProps)
            SetVehicleNumberPlateText(vehicle, vehicleData.vehicleProps.plate)
          end)

          Citizen.Wait(400)

          utils.ui.showNotification("You have taken your vehicle out of the garage.")
        end
      end, vehicleData.vehicleProps.plate)
    end
  end)
end

-----------------------------------------------------------------------------------
-- LOGIC FUNCTIONS
-----------------------------------------------------------------------------------

module.EnterGarage = function(data)
  camera.start()
  module.mainCameraScene()
  camera.setPolarAzimuthAngle(250.0, 120.0)
  camera.setRadius(3.5)

  Citizen.CreateThread(function()
    local ped = PlayerPedId()

    local pos = vector3(227.6369, -990.8311, -99.06071)
    SetEntityCoords(ped, module.Config.GarageMenuLocation)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false)
  end)
end

module.ExitGarage = function()
  Citizen.CreateThread(function()
    local ped = PlayerPedId()

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
  end)

  emit('esx:identity:preventSaving', false)

  module.isInGarageMenu = false
end

module.ExitGarageWithSelectedVehicle = function()
  Citizen.CreateThread(function()
    DoScreenFadeOut(250)

    while not IsScreenFadedOut() do
      Citizen.Wait(0)
    end

    if module.currentDisplayVehicle then
      module.DeleteDisplayVehicleInsideGarage()
      module.currentDisplayVehicle = nil
      module.vehicleLoaded = false
    end

    if module.retrievalMenu then
      module.retrievalMenu:destroy()
    end

    module.DestroyGarageMenu()
    camera.destroy()

    emit('esx:identity:preventSaving', false)
    module.isInGarageMenu = false
    module.Exit()

    Citizen.Wait(400)

    DoScreenFadeIn(500)
  end)
end

module.StartGarageRestriction = function()
  Citizen.CreateThread(function()
    while module.isInGarageMenu do
      Citizen.Wait(0)

      DisableControlAction(0, 75,  true)
      DisableControlAction(27, 75, true)
    end
  end)
end

module.showVehicleStats = function()
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      if module.vehicleLoaded then
        local playerPed = PlayerPedId()

        if IsPedSittingInAnyVehicle(playerPed) then
          local vehicle = GetVehiclePedIsIn(playerPed, false)

          if DoesEntityExist(vehicle) then
            local model            = GetEntityModel(vehicle, false)
            local hash             = GetHashKey(model)

            local topSpeed         = GetVehicleMaxSpeed(vehicle) * 3.6
            local acceleration     = GetVehicleModelAcceleration(model)
            local gears            = GetVehicleHighGear(vehicle)
            local capacity         = GetVehicleMaxNumberOfPassengers(vehicle) + 1

            local topSpeedStat     = (((topSpeed / module.Config.fastestVehicleSpeed) / 2) * module.Config.statSizeX)
            local accelerationStat = (((acceleration / 1.6) / 2) * module.Config.statSizeX)
            local gearStat         = tostring(gears)
            local capacityStat     = tostring(capacity)

            if topSpeedStat > 0.24 then
              topSpeedStat = 0.24
            end

            if accelerationStat > 0.24 then
              accelerationStat = 0.24
            end

            utils.ui.drawVehicleStats(module.Config.xoffset, module.Config.yoffset, module.Config.windowSizeX, module.Config.windowSizeY, module.Config.statOffsetX, module.Config.statSizeX, module.Config.statSizeY, topSpeedStat, accelerationStat, gearStat, capacityStat)
          end
        end
      else
        break
      end
    end
  end)
end

module.SetMouseIn = function(value)
  camera.setMouseIn(value)
end

module.commit = function(vehicleData, data)
  local playerPed = PlayerPedId()

  module.DeleteDisplayVehicleInsideGarage()

  utils.game.waitForVehicleToLoad(vehicleData.model)

  utils.game.createLocalVehicle(vehicleData.model, module.Config.GarageMenuLocation, module.Config.GarageMenuLocatioHeading, function(vehicle)
    module.currentDisplayVehicle = vehicle
    
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    utils.game.setVehicleProperties(vehicle, vehicleData.vehicleProps)

    FreezeEntityPosition(vehicle, true)

    local model = GetEntityModel(vehicle)

    SetModelAsNoLongerNeeded(model)

    module.OpenRetrievalMenu(vehicleData, data)

    module.vehicleLoaded = true

    if module.Config.EnableVehicleStats then
      module.showVehicleStats()
    end
  end)
end

module.DeleteDisplayVehicleInsideGarage = function()
  local attempt = 0

  if module.currentDisplayVehicle and DoesEntityExist(module.currentDisplayVehicle) then
    while DoesEntityExist(module.currentDisplayVehicle) and not NetworkHasControlOfEntity(module.currentDisplayVehicle) and attempt < 100 do
      Citizen.Wait(100)
      NetworkRequestControlOfEntity(module.currentDisplayVehicle)
      attempt = attempt + 1
    end

    if DoesEntityExist(module.currentDisplayVehicle) and NetworkHasControlOfEntity(module.currentDisplayVehicle) then
      utils.game.deleteVehicle(module.currentDisplayVehicle)
      module.currentDisplayVehicle = nil
      module.vehicleLoaded = false
    end
  end
end

module.ReturnPlayer = function(pos)
  local ped = PlayerPedId()
  SetEntityCoords(ped, pos)

  Citizen.Wait(500)
  DoScreenFadeIn(250)
end

module.DestroyGarageMenu = function()
  module.garageMenu:destroy()
end

module.Exit = function()
  module.CurrentAction     = nil
  module.CurrentActionData = nil
  module.inMarker          = false

  Interact.StopHelpNotification()
end

module.StoreVehicle = function()
  local playerPed = PlayerPedId()

  if IsPedSittingInAnyVehicle(playerPed) then
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
      local plate        = utils.math.Trim(GetVehicleNumberPlateText(vehicle))
      local vehicleProps = utils.game.getVehicleProperties(vehicle)

      request('garages:checkOwnedVehicle', function(result)
        if result then
          emitServer('garages:updateVehicle', plate, vehicleProps)
          emitServer('garages:storeVehicle', plate)
          DoScreenFadeOut(250)

          while not IsScreenFadedOut() do
          Citizen.Wait(0)
          end

          utils.game.deleteVehicle(vehicle)

          Citizen.Wait(500)
          utils.ui.showNotification("You have stored your vehicle in the garage.")
          DoScreenFadeIn(250)
        elseif not result then 
          utils.ui.showNotification("~r~You must own this vehicle in order to use this marker.")
        end
      end, plate)
    end
  end

  module.Exit()
end

-----------------------------------------------------------------------------------
-- CAMERA FUNCTIONS
-----------------------------------------------------------------------------------

function module.mainCameraScene()
  local ped       = GetPlayerPed(-1)
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)
  
  camera.setRadius(1.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  
  camera.pointToBone(SKEL_ROOT)
end
