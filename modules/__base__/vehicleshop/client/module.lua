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
local HUD      = M('game.hud')
local utils    = M("utils")
local camera   = M("camera")
local vehicles = M("vehicles")

module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.enableVehicleStats             = true
module.drawDistance                   = 30
module.plateLetters                   = 3
module.plateNumbers                   = 3
module.plateUseSpace                  = true
module.resellPercentage               = 50
module.numberCharset                  = {}
module.charset                        = {}

module.xoffset                        = 0.6
module.yoffset                        = 0.122
module.windowSizeX                    = 0.25
module.windowSizY                     = 0.15
module.statSizeX                      = 0.24
module.statSizeY                      = 0.01
module.statOffsetX                    = 0.55
module.fastestVehicleSpeed            = 200

module.currentDisplayVehicle          = nil
module.hasAlreadyEnteredMarker        = false
module.isInShopMenu                   = false
module.letSleep                       = nil
module.currentDisplayVehicle          = nil
module.currentVehicleData             = nil
module.currentMenu                    = nil
module.vehicle                        = nil
module.vehicleData                    = nil
module.savedPosition                  = nil

module.playerDied                     = false
module.inTestDrive                    = false
module.testDriveTime                  = 0

module.categories                     = {}
module.vehicles                       = {}

module.active                         = false
module.inMarker                       = false
module.inSellMarker                   = false

module.selectedVehicle                = module.selectedVehicle or 1
module.selectedCategory               = module.selectedCategory or nil

-----------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------

module.Init = function()

  local translations = run('data/locales/' .. module.Config.Locale .. '.lua')['Translations']
  LoadLocale('vehicleshop', module.Config.Locale, translations)

  Citizen.CreateThread(function()
    RequestIpl('shr_int') -- Load walls and floor

    local interiorID = 7170
    LoadInterior(interiorID)
    EnableInteriorProp(interiorID, 'csr_beforeMission') -- Load large window
    RefreshInterior(interiorID)
  end)

  Citizen.CreateThread(function()
    local blip = AddBlipForCoord(module.Config.VehicleShopZones.Main.Center)

    SetBlipSprite (blip, 664)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Car Dealership (Buy)")
    EndTextCommandSetBlipName(blip)
    SetBlipColour (blip,2)
  end)

  Citizen.CreateThread(function()
    local blip2 = AddBlipForCoord(module.Config.Zones.ShopSell.Pos)

    SetBlipSprite (blip2, 108)
    SetBlipDisplay(blip2, 4)
    SetBlipScale  (blip2, 0.9)
    SetBlipAsShortRange(blip2, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Car Dealership (Sell)")
    EndTextCommandSetBlipName(blip2)
    SetBlipColour (blip2,1)
  end)

  for k, v in pairs(module.Config.Zones) do
    local key = 'vehicleshop:' .. tostring(k)

    Interact.Register({
      name         = key,
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

      if data.name == "vehicleshop:ShopSell" then
        if not module.inTestDrive then
          local ped = PlayerPedId()

          if IsPedSittingInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then

              Interact.ShowHelpNotification("Press ~INPUT_CONTEXT~ to sell this vehicle")

              module.CurrentAction = function()
                module.SellVehicle()
              end

              if not module.inMarker then
                module.inSellMarker = true
              end
            else
              Interact.ShowHelpNotification("~r~You must be the driver of the vehicle to use this.")

            end
          else
            Interact.ShowHelpNotification("You must be in a vehicle to use this.")

          end
        end
      end
    end)

    on('esx:interact:exit:' .. key, function(data) 
      module.CurrentAction = nil
      module.inSellMarker      = false

      Interact.StopHelpNotification()
    end)

    on('vehicleshop:enteredZone', function()
      if not module.inTestDrive then
        Interact.ShowHelpNotification("Press ~INPUT_CONTEXT~ to access the vehicle shop.")

        module.CurrentAction = function()
          module.OpenShopMenu()
        end
      end
    end)

    on('vehicleshop:exitedZone', function()
      module.CurrentAction = nil
      module.inMarker      = false

      Interact.StopHelpNotification()
    end)

  end
end

-----------------------------------------------------------------------------------
-- DO NOT EDIT
-----------------------------------------------------------------------------------

for i = 48, 57 do
  table.insert(module.numberCharset, string.char(i))
end

for i = 65, 90 do
  table.insert(module.charset, string.char(i))
end

for i = 97, 122 do
  table.insert(module.charset, string.char(i))
end

-----------------------------------------------------------------------------------
-- MENU
-----------------------------------------------------------------------------------

module.DestroyShopMenu = function()
  module.shopMenu:destroy()
end

module.SaveCurrentPosition = function()
  module.savedPosition = GetEntityCoords(PlayerPedId(), true)
end

module.OpenShopMenu = function()

  module.inMenu = true

  module.SaveCurrentPosition()

  request("vehicleshop:getCategories", function(categories)
    module.categories = categories

    module.EnterShop()

    local items = {}

    if module.categories then
      for k,v in pairs(module.categories) do

        local category = v.category
        local label    = v.categoryLabel

        items[#items + 1] = {type= 'button', name = category, label = label}
      end
    end

    items[#items + 1] = {type= 'button', name = 'exit', label = ">> Exit <<"}

    module.shopMenu = Menu('vehicleshop.main', {
      title = 'Vehicle Shop',
      float = 'top|left', -- not needed, default value
      items = items
    })

    module.currentMenu = module.shopMenu

    module.shopMenu:on('item.click', function(item, index)
      if item.name == 'exit' then
        module.DestroyShopMenu()
        DoScreenFadeOut(250)

        while not IsScreenFadedOut() do
          Citizen.Wait(0)
        end

        module.ExitShop()
      else
        module.OpenCategoryMenu(item.name, item.label)
      end
    end)
  end)
end


on('ui.menu.mouseChange', function(value)
  if module.isInShopMenu then
    camera.setMouseIn(value)
  end
end)

module.OpenCategoryMenu = function(category, categoryLabel)

  request("vehicleshop:getVehicles", function(vehicles)
    module.vehicles = vehicles

    local items = {}

    for k,v in pairs(module.vehicles) do
      if category == v.category then
        local vehicleData = {
          name          = v.name,
          model         = v.model,
          price         = v.price,
          category      = v.category,
          categoryLabel = v.categorylabel
        }

        items[#items + 1] = {type = 'button', name = vehicleData, label = v.name .. " - $" .. module.GroupDigits(v.price)}
      end
    end

    items[#items + 1] = {name = 'back', label = '>> Back <<', type = 'button'}

    if module.shopMenu.visible then
      module.shopMenu:hide()
    end

    module.categoryMenu = Menu('vehicleshop.category', {
      title = tostring(categoryLabel),
      float = 'top|left', -- not needed, default value
      items = items
    })

    module.currentMenu = module.categoryMenu

    module.categoryMenu:on('destroy', function()
      module.shopMenu:show()
    end)

    module.categoryMenu:on('item.click', function(item, index)
      if item.name == 'back' then
        if module.currentDisplayVehicle then
          module.DeleteDisplayVehicleInsideShop()
          module.currentDisplayVehicle = nil 
        end

        module.categoryMenu:destroy()

        module.currentMenu = module.shopMenu

        module.shopMenu:focus()
      else
        module.OpenBuyMenu(category, categorylabel, item.name)
      end
    end)
  end)
end

module.OpenBuyMenu = function(category, categorylabel, vehicleData)

  module.commit(vehicleData.model)

  local items = {}

  items[#items + 1] = {name = 'yes', label = '>> Yes <<', type = 'button', value = category[model]}
  items[#items + 1] = {name = 'no', label = '>> No <<', type = 'button'}
  items[#items + 1] = {name = 'testdrive', label = '>> Test Drive <<', type = 'button'}

  module.lastMenu = module.currentMenu

  if module.lastMenu.visible then
    module.lastMenu:hide()
  end

  module.buyMenu = Menu('vehicleshop.buy', {
    title = "Buy " .. vehicleData.name .. " for $" .. module.GroupDigits(vehicleData.price) .. "?",
    float = 'top|left', -- not needed, default value
    items = items
  })
  
  module.currentMenu = module.buyMenu

  module.buyMenu:on('destroy', function()
    module.lastMenu:show()
  end)

  module.buyMenu:on('item.click', function(item, index)
    if item.name == 'no' then
      module.DeleteDisplayVehicleInsideShop()
      module.currentDisplayVehicle = nil

      module.buyMenu:destroy()

      module.currentMenu = module.lastMenu

      module.lastMenu:focus()
    elseif item.name == 'testdrive' then
      module.ExitShopFromMenuTestDrive()

      while not IsScreenFadedOut() do
        Citizen.Wait(0)
      end

      module.startTestDrive(vehicleData.model)
    elseif item.name == 'yes' then

      local generatedPlate = module.GeneratePlate()
      local buyPrice = vehicleData.price
      local formattedPrice = module.GroupDigits(vehicleData.price)
      local displaytext = GetDisplayNameFromVehicleModel(vehicleData.model)
      local name = GetLabelText(displaytext)
      local ped = PlayerPedId()
      local resellPrice = math.round(vehicleData.price / 100 * module.resellPercentage)

      if not generatedPlate then
        print("Failure to generate plate. Please contact the server administrator.")
      else
        request('vehicleshop:buyVehicle', function(result)
          if result then
            local ped = PlayerPedId()
            
            module.ExitShopFromMenu()

            while not IsScreenFadedOut() do
              Citizen.Wait(0)
            end

            FreezeEntityPosition(ped, false)

            utils.game.createVehicle(vehicleData.model, module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading, function(vehicle)
              local ped = PlayerPedId()
              SetEntityVisible(ped, true)
              TaskWarpPedIntoVehicle(ped, vehicle, -1)
              SetVehicleNumberPlateText(vehicle, generatedPlate)
              local vehicleProps = module.GetVehicleProperties(vehicle)
              emitServer('vehicleshop:updateVehicle', vehicleProps, generatedPlate)
            end)

            Citizen.Wait(400)

            utils.ui.showNotification("You have bought a ~y~" .. name .. "~s~ with the plates ~b~" .. generatedPlate .. "~s~ for ~g~$" .. formattedPrice)
          else
            
            if module.currentDisplayVehicle then
              module.DeleteDisplayVehicleInsideShop()
              module.currentDisplayVehicle = nil
              module.vehicleLoaded         = false
            end
          
            module.BuyMenu:destroy()
          
            module.currentMenu = module.lastMenu
          
            module.lastMenu:focus()
          end
        end, vehicleData.model, generatedPlate, buyPrice, formattedPrice, vehicleData.name, name, resellPrice)
      end
    end
  end)
end

module.startTestDrive = function(car)

  module.playerDied = false

  module.SaveCurrentPosition()

  local playerPed = PlayerPedId()

  module.testDriveTime = tonumber(module.Config.TestDriveTime)

  PlaySoundFrontend(-1, "Player_Enter_Line", "GTAO_FM_Cross_The_Line_Soundset", 0)

  utils.game.requestModel(GetHashKey(car))

  while not HasModelLoaded(GetHashKey(car)) do
    Citizen.Wait(0)
  end

  utils.ui.showNotification("Test Drive Started.")

  local testVeh = CreateVehicle(GetHashKey(car), module.Config.ShopOutside.Pos, module.Config.ShopOutside.Heading,  996.786, 25.1887, false, false)

  Citizen.Wait(150)

  SetEntityAsMissionEntity(testVeh)
  SetVehicleLivery(testVeh, 0)
  TaskWarpPedIntoVehicle(PlayerPedId(), testVeh, - 1)
  SetVehicleNumberPlateText(testVeh, "RENTAL")
  SetVehicleColours(testVeh, 111,111)
  SetPedCanBeKnockedOffVehicle(PlayerPedId(),1)
  SetPedCanRagdoll(PlayerPedId(),false)
  SetEntityVisible(playerPed, true)

  Citizen.Wait(500)

  DoScreenFadeIn(300)

  module.inTestDrive = true

  if not DoesEntityExist(testVeh) then
    module.testDriveTime = 0
  end

  while module.inTestDrive do

    Citizen.Wait(0)
    DisableControlAction(0, 75, true)
    DisableControlAction(27, 75, true)
    DisableControlAction(0, 70, true)
    DisableControlAction(0, 69, true)

    if IsEntityDead(PlayerPedId()) then
      module.playerDied    = true
      module.inTestDrive   = false
      module.testDriveTime = 0
    else
      local pedCoords = GetEntityCoords(PlayerPedId())

      module.testDriveTime = module.testDriveTime - 0.009

      if math.floor(module.testDriveTime) >= 60 then
        utils.ui.showHelpNotification("~INPUT_CONTEXT~ To End Early - Time Remaining: ~g~" .. math.floor(module.testDriveTime), false, false, 1)
      elseif math.floor(module.testDriveTime) >= 20 and math.floor(module.testDriveTime) < 60 then
        utils.ui.showHelpNotification("~INPUT_CONTEXT~ To End Early - Time Remaining: ~y~" .. math.floor(module.testDriveTime), false, false, 1)
      elseif math.floor(module.testDriveTime) < 20 then
        utils.ui.showHelpNotification("~INPUT_CONTEXT~ To End Early - Time Remaining: ~r~" .. math.floor(module.testDriveTime), false, false, 1)
      end

      if module.testDriveTime <= 0 then
        module.inTestDrive = false
      end
    end
  end

  if module.playerDied then
    utils.ui.showNotification("Test Drive Ended Due To Death5.")
  else
    Interact.StopHelpNotification()

    SetPedCanRagdoll(PlayerPedId(),true)
    SetPedCanBeKnockedOffVehicle(PlayerPedId(),0)
    PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)

    DoScreenFadeOut(300)

    Citizen.Wait(500)

    DeleteEntity(testVeh)
    FreezeEntityPosition(PlayerPedId(), true)

    Citizen.Wait(500)

    FreezeEntityPosition(PlayerPedId(), false)
    utils.ui.showNotification("Test Drive Ended.")

    DoScreenFadeIn(300)

    FreezeEntityPosition(playerPed, false)

    SetEntityCoords(playerPed, module.savedPosition)

    emit('esx:identity:preventSaving', false)
  end
end

-----------------------------------------------------------------------------------
-- Shop Sub-Menu 2 Functions
-----------------------------------------------------------------------------------

module.GetVehicleProperties = function(vehicle)
  if DoesEntityExist(vehicle) then
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local extras = {}

    for extraId=0, 12 do
      if DoesExtraExist(vehicle, extraId) then
        local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
        extras[tostring(extraId)] = state
      end
    end

    return {
      model             = GetEntityModel(vehicle),

      plate             = module.Trim(GetVehicleNumberPlateText(vehicle)),
      plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

      bodyHealth        = math.round(GetVehicleBodyHealth(vehicle), 1),
      engineHealth      = math.round(GetVehicleEngineHealth(vehicle), 1),
      tankHealth        = math.round(GetVehiclePetrolTankHealth(vehicle), 1),

      fuelLevel         = math.round(GetVehicleFuelLevel(vehicle), 1),
      dirtLevel         = math.round(GetVehicleDirtLevel(vehicle), 1),
      color1            = colorPrimary,
      color2            = colorSecondary,

      pearlescentColor  = pearlescentColor,
      wheelColor        = wheelColor,

      wheels            = GetVehicleWheelType(vehicle),
      windowTint        = GetVehicleWindowTint(vehicle),
      xenonColor        = GetVehicleXenonLightsColour(vehicle),

      neonEnabled       = {
        IsVehicleNeonLightEnabled(vehicle, 0),
        IsVehicleNeonLightEnabled(vehicle, 1),
        IsVehicleNeonLightEnabled(vehicle, 2),
        IsVehicleNeonLightEnabled(vehicle, 3)
      },

      neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
      extras            = extras,
      tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

      modSpoilers       = GetVehicleMod(vehicle, 0),
      modFrontBumper    = GetVehicleMod(vehicle, 1),
      modRearBumper     = GetVehicleMod(vehicle, 2),
      modSideSkirt      = GetVehicleMod(vehicle, 3),
      modExhaust        = GetVehicleMod(vehicle, 4),
      modFrame          = GetVehicleMod(vehicle, 5),
      modGrille         = GetVehicleMod(vehicle, 6),
      modHood           = GetVehicleMod(vehicle, 7),
      modFender         = GetVehicleMod(vehicle, 8),
      modRightFender    = GetVehicleMod(vehicle, 9),
      modRoof           = GetVehicleMod(vehicle, 10),

      modEngine         = GetVehicleMod(vehicle, 11),
      modBrakes         = GetVehicleMod(vehicle, 12),
      modTransmission   = GetVehicleMod(vehicle, 13),
      modHorns          = GetVehicleMod(vehicle, 14),
      modSuspension     = GetVehicleMod(vehicle, 15),
      modArmor          = GetVehicleMod(vehicle, 16),

      modTurbo          = IsToggleModOn(vehicle, 18),
      modSmokeEnabled   = IsToggleModOn(vehicle, 20),
      modXenon          = IsToggleModOn(vehicle, 22),

      modFrontWheels    = GetVehicleMod(vehicle, 23),
      modBackWheels     = GetVehicleMod(vehicle, 24),

      modPlateHolder    = GetVehicleMod(vehicle, 25),
      modVanityPlate    = GetVehicleMod(vehicle, 26),
      modTrimA          = GetVehicleMod(vehicle, 27),
      modOrnaments      = GetVehicleMod(vehicle, 28),
      modDashboard      = GetVehicleMod(vehicle, 29),
      modDial           = GetVehicleMod(vehicle, 30),
      modDoorSpeaker    = GetVehicleMod(vehicle, 31),
      modSeats          = GetVehicleMod(vehicle, 32),
      modSteeringWheel  = GetVehicleMod(vehicle, 33),
      modShifterLeavers = GetVehicleMod(vehicle, 34),
      modAPlate         = GetVehicleMod(vehicle, 35),
      modSpeakers       = GetVehicleMod(vehicle, 36),
      modTrunk          = GetVehicleMod(vehicle, 37),
      modHydrolic       = GetVehicleMod(vehicle, 38),
      modEngineBlock    = GetVehicleMod(vehicle, 39),
      modAirFilter      = GetVehicleMod(vehicle, 40),
      modStruts         = GetVehicleMod(vehicle, 41),
      modArchCover      = GetVehicleMod(vehicle, 42),
      modAerials        = GetVehicleMod(vehicle, 43),
      modTrimB          = GetVehicleMod(vehicle, 44),
      modTank           = GetVehicleMod(vehicle, 45),
      modWindows        = GetVehicleMod(vehicle, 46),
      modLivery         = GetVehicleLivery(vehicle)
    }
  else
    return
  end
end

-----------------------------------------------------------------------------------
-- Vehicle Model Loading Functions
-----------------------------------------------------------------------------------

module.commit = function(model)
  local ped = PlayerPedId()

  module.DeleteDisplayVehicleInsideShop()
  module.currentDisplayVehicle = nil
  module.vehicleLoaded         = false

  module.WaitForVehicleToLoad(model)

  utils.game.createLocalVehicle(model, module.Config.ShopInside.Pos, module.Config.ShopInside.Heading, function(vehicle)
    module.currentDisplayVehicle = vehicle
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    FreezeEntityPosition(vehicle, true)
    SetModelAsNoLongerNeeded(model)
    module.vehicleLoaded = true
    if module.enableVehicleStats then
      module.showVehicleStats()
    end
  end)
end

module.RenderBox = function(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
  DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4)
end

module.DrawText = function(string, x, y)
  SetTextFont(2)
  SetTextProportional(0)
  SetTextScale(0.5, 0.5)
  SetTextColour(255, 255, 255, 255)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(2)
  SetTextEntry("STRING")
  AddTextComponentString(string)
  DrawText(x,y)
end

module.showVehicleStats = function()
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      if module.vehicleLoaded then
        local ped = PlayerPedId()

        if IsPedSittingInAnyVehicle(ped) then
          local vehicle = GetVehiclePedIsIn(ped, false)

          if DoesEntityExist(vehicle) then
            local model            = GetEntityModel(vehicle, false)
            local hash             = GetHashKey(model)

            local topSpeed         = GetVehicleMaxSpeed(vehicle) * 3.6
            local acceleration     = GetVehicleModelAcceleration(model)
            local gears            = GetVehicleHighGear(vehicle)
            local capacity         = GetVehicleMaxNumberOfPassengers(vehicle) + 1

            local topSpeedStat     = (((topSpeed / module.fastestVehicleSpeed) / 2) * module.statSizeX)
            local accelerationStat = (((acceleration / 1.6) / 2) * module.statSizeX)
            local gearStat         = tostring(gears)
            local capacityStat     = tostring(capacity)

            if topSpeedStat > 0.24 then
              topSpeedStat = 0.24
            end

            if accelerationStat > 0.24 then
              accelerationStat = 0.24
            end
      
            module.RenderBox(module.xoffset - 0.05, module.windowSizeX, (module.yoffset - 0.0325), module.windowSizY, 0, 0, 0, 225)

            module.DrawText("Top Speed", module.xoffset - 0.146, module.yoffset - 0.105)
            module.RenderBox(module.statOffsetX, module.statSizeX, (module.yoffset - 0.07), module.statSizeY, 60, 60, 60, 225)
            module.RenderBox(module.statOffsetX - ((module.statSizeX - topSpeedStat) / 2), topSpeedStat, (module.yoffset - 0.07), module.statSizeY, 0, 255, 255, 225)

            module.DrawText("Acceleration", module.xoffset - 0.138, module.yoffset - 0.065)
            module.RenderBox(module.statOffsetX, module.statSizeX, (module.yoffset - 0.03), module.statSizeY, 60, 60, 60, 225)
            module.RenderBox(module.statOffsetX - ((module.statSizeX - (accelerationStat * 4)) / 2), accelerationStat * 4, (module.yoffset - 0.03), module.statSizeY, 0, 255, 255, 225)

            module.DrawText("Gears", module.xoffset - 0.1565, module.yoffset - 0.025)
            module.DrawText(gearStat, module.xoffset + 0.068, module.yoffset - 0.025)

            module.DrawText("Seating Capacity", module.xoffset - 0.1275, module.yoffset + 0.002)
            module.DrawText(capacityStat, module.xoffset + 0.068, module.yoffset + 0.002)
          end
        end
      else
        break
      end
    end
  end)
end

-----------------------------------------------------------------------------------
-- BASE FUNCTIONS
-----------------------------------------------------------------------------------

module.SellVehicle = function()
  local ped = PlayerPedId()

  if IsPedSittingInAnyVehicle(ped) then
    local vehicle = GetVehiclePedIsIn(ped, false)

    if GetPedInVehicleSeat(vehicle, -1) == ped then
      local plate = module.Trim(GetVehicleNumberPlateText(vehicle))

      request("vehicleshop:checkOwnedVehicle", function(vehicleData)
        if vehicleData then

          local modelName = GetEntityModel(vehicle)
          local displaytext = GetDisplayNameFromVehicleModel(modelName)
          local name = GetLabelText(displaytext)
    
          for k,v in pairs(module.vehicles) do
            if v.model == vehicleData.model then

              local formattedPrice = module.GroupDigits(vehicleData.resellPrice)

              request("vehicleshop:sellVehicle", function(success)
                if success then
                  DoScreenFadeOut(250)

                  while not IsScreenFadedOut() do
                    Citizen.Wait(0)
                  end
                  
                  utils.ui.showNotification("You have sold your ~y~" .. name .. "~s~ with the plates ~b~" .. plate .. "~s~ for ~g~$" .. formattedPrice)
                  module.DeleteVehicle(vehicle)

                  Citizen.Wait(500)
                  DoScreenFadeIn(250)
                end
              end, plate, name, vehicleData.resellPrice, formattedPrice)

              break
            end
          end
        end
      end, plate)
    end
  end
end

module.GroupDigits = function(value)
  local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

  return left..(num:reverse():gsub('(%d%d%d)','%1' .. ","):reverse())..right
end

module.Trim = function(value)
  if value then
    return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
  else
    return nil
  end
end

module.GeneratePlate = function()
  local generatedPlate
  local doBreak  = false
  local attempts = 0

  while true do
    Citizen.Wait(2)

    if attempts > 100 then
      generatedPlate = nil
      break
    else
      math.randomseed(GetGameTimer())

      if module.plateUseSpace then
        generatedPlate = string.upper(module.GetRandomLetter(module.plateLetters) .. ' ' .. module.GetRandomNumber(module.plateNumbers))
      else
        generatedPlate = string.upper(module.GetRandomLetter(module.plateLetters) .. module.GetRandomNumber(module.plateNumbers))
      end

      request('vehicleshop:isPlateTaken', function(isPlateTaken)
        if not isPlateTaken then
          doBreak = true
        end
      end, generatedPlate, module.plateUseSpace, module.plateLetters, module.PlateNumbers)

      if doBreak then
        break
      end

      attempts = attempts + 1
    end   
  end

  return generatedPlate
end

module.IsPlateTaken = function(plate)
  local callback = 'waiting'

  request('vehicleshop:isPlateTaken', function(isPlateTaken)
    callback = isPlateTaken
  end, plate)

  while type(callback) == 'string' do
    Citizen.Wait(0)
  end

  return callback
end

module.GetRandomNumber = function(length)
  Citizen.Wait(0)
  math.randomseed(GetGameTimer())
  if length > 0 then
    return module.GetRandomNumber(length - 1) .. module.numberCharset[math.random(1, #module.numberCharset)]
  else
    return ''
  end
end

module.GetRandomLetter = function(length)
  Citizen.Wait(0)
  math.randomseed(GetGameTimer())
  if length > 0 then
    return module.GetRandomLetter(length - 1) .. module.charset[math.random(1, #module.charset)]
  else
    return ''
  end
end

module.GetVehicleLabelFromModel = function(model)
  for k,v in ipairs(Vehicles) do
    if v.model == model then
      return v.name
    end
  end

  return
end

module.StartShopRestriction = function()
  Citizen.CreateThread(function()
    while module.isInShopMenu do
      Citizen.Wait(0)

      DisableControlAction(0, 75,  true)
      DisableControlAction(27, 75, true)
    end
  end)
end

module.EnterShop = function()

  module.isInShopMenu = true

  module.StartShopRestriction()
  
  DoScreenFadeOut(250)

  while not IsScreenFadedOut() do
    Citizen.Wait(0)
  end

  camera.start()
  module.mainCameraScene()

  Citizen.CreateThread(function()
    local ped = PlayerPedId()

    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false)
    SetEntityCoords(ped, module.Config.ShopInside.Pos)
  end)

  Citizen.Wait(500)

  camera.setPolarAzimuthAngle(250.0, 120.0)
  camera.setRadius(3.5)
  emit('esx:identity:preventSaving', true)

  DoScreenFadeIn(250)
end

module.ExitShop = function()
  Citizen.CreateThread(function()
    if module.buyMenu then
      module.buyMenu:destroy()
    end

    if module.lastMenu then
      module.lastMenu:destroy()
    end

    module.DestroyShopMenu()
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
    module.ReturnPlayer()
    camera.destroy()
    emit('esx:identity:preventSaving', false)
  end)

  module.isInShopMenu = false
end

module.ExitShopFromMenu = function()
  Citizen.CreateThread(function()
    DoScreenFadeOut(250)

    while not IsScreenFadedOut() do
      Citizen.Wait(0)
    end
  
    if module.currentDisplayVehicle then
      module.DeleteDisplayVehicleInsideShop()
      module.currentDisplayVehicle = nil
      module.vehicleLoaded         = false
    end
  
  
    Citizen.Wait(100)

    if module.buyMenu then
      module.buyMenu:destroy()
    end

    if module.lastMenu then
      module.lastMenu:destroy()
    end

    module.DestroyShopMenu()
    camera.destroy()
    emit('esx:identity:preventSaving', false)

    module.isInShopMenu = false

    Citizen.Wait(400)

    DoScreenFadeIn(500)
  end)
end

module.ExitShopFromMenuTestDrive = function()
  Citizen.CreateThread(function()
    DoScreenFadeOut(250)

    while not IsScreenFadedOut() do
      Citizen.Wait(0)
    end
  
    if module.currentDisplayVehicle then
      module.DeleteDisplayVehicleInsideShop()
      module.currentDisplayVehicle = nil
      module.vehicleLoaded         = false
    end
  
  
    Citizen.Wait(100)

    if module.buyMenu then
      module.buyMenu:destroy()
    end

    if module.lastMenu then
      module.lastMenu:destroy()
    end

    module.DestroyShopMenu()
    camera.destroy()

    module.isInShopMenu = false

    Citizen.Wait(400)

    DoScreenFadeIn(500)
  end)
end

module.ReturnPlayer = function()
  local ped = PlayerPedId()
  if module.savedPosition then
    SetEntityCoords(ped, module.savedPosition)
  else
    SetEntityCoords(ped, module.Config.VehicleShopZones.Main.Center)
  end

  Citizen.Wait(1000)
  DoScreenFadeIn(250)
end

module.WaitForVehicleToLoad = function(modelHash)
  modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

  if not HasModelLoaded(modelHash) then
    utils.game.requestModel(modelHash)

    BeginTextCommandBusyspinnerOn('STRING')
    AddTextComponentSubstringPlayerName("Please wait for the model to load...")
    EndTextCommandBusyspinnerOn(4)

    while not HasModelLoaded(modelHash) do
      Citizen.Wait(0)
      DisableAllControlActions(0)
    end

    BusyspinnerOff()
  end
end

module.DeleteDisplayVehicleInsideShop = function()
  local attempt = 0

  if module.currentDisplayVehicle and DoesEntityExist(module.currentDisplayVehicle) then
    while DoesEntityExist(module.currentDisplayVehicle) and not NetworkHasControlOfEntity(module.currentDisplayVehicle) and attempt < 100 do
      Citizen.Wait(100)
      NetworkRequestControlOfEntity(module.currentDisplayVehicle)
      attempt = attempt + 1
    end

    if DoesEntityExist(module.currentDisplayVehicle) and NetworkHasControlOfEntity(module.currentDisplayVehicle) then
      module.DeleteVehicle(module.currentDisplayVehicle)
      module.vehicleLoaded = false
    end
  end
end

module.DeleteVehicle = function(vehicle)
  SetEntityAsMissionEntity(vehicle, false, true)
  DeleteVehicle(vehicle)
end

module.mainCameraScene = function()
  local ped       = PlayerPedId()
  local pedCoords = GetEntityCoords(ped)
  local forward   = GetEntityForwardVector(ped)
  
  camera.setRadius(1.25)
  camera.setCoords(pedCoords + forward * 1.25)
  camera.setPolarAzimuthAngle(utils.math.world3DtoPolar3D(pedCoords, pedCoords + forward * 1.25))
  
  camera.pointToBone(SKEL_ROOT)
end
