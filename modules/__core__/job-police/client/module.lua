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
M('role')
local utils = M('utils')
local Society = M('society')
local Menu = M('ui.menu')

local chosen_fines = {}

module.Config = ESX.EvalFile(GetCurrentResourceName(), 'modules/__core__/job-police/data/config.lua', {
    vector3 = vector3
})['Config']

module.Init = function()

  local translations = ESX.EvalFile(GetCurrentResourceName(), 'modules/__core__/job-police/data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('society', Config.Locale, translations)

end

-- Cuffing Module
module.cuffPlayer = function()
  local playerPed = PlayerPedId()

  RequestAnimDict('mp_arresting')
  while not HasAnimDictLoaded('mp_arresting') do
    Citizen.Wait(100)
  end

  TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

  SetEnableHandcuffs(playerPed, true)
  DisablePlayerFiring(playerPed, true)
  SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
  SetPedCanPlayGestureAnims(playerPed, false)
  FreezeEntityPosition(playerPed, true)

  if Config.EnableHandcuffTimer then
    if handcuffTimer.active then
      ESX.ClearTimeout(handcuffTimer.task)
    end

    module.StartHandcuffTimer()
  end

end

-- Uncuffing Module
module.uncuffPlayer = function()
  local playerPed = PlayerPedId()

  ClearPedSecondaryTask(playerPed)
  SetEnableHandcuffs(playerPed, false)
  DisablePlayerFiring(playerPed, false)
  SetPedCanPlayGestureAnims(playerPed, true)
  FreezeEntityPosition(playerPed, false)

  if Config.EnableHandcuffTimer and handcuffTimer.active then
    ESX.ClearTimeout(handcuffTimer.task)
  end

end

-- Uncuff player after X time
module.StartHandcuffTimer = function()

  if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		ESX.ShowNotification(_U('unrestrained_timer'))
		emit('esx_policejob:unrestrain')
		handcuffTimer.active = false
	end)

end

-- Job Menu
module.openJobMenu = function()

  module.job_menu = Menu('job_menu', {
    title = "Job Menu",
    float = "top|left",
    items = {
      {name = 'search',         label = "Search",           type = "button"},
      {name = 'cuff',           label = "Cuff",             type = "button"},
      {name = 'drag',           label = "Drag",             type = "button"},
      {name = 'jail',           label = "Jail",             type = "button"},
      {name = 'fine',           label = "Fine",             type = "button"},
      {name = 'put_vehicle',    label = "Put in vehicle",   type = "button"},
      {name = 'exit',           label = "Exit",             type = "button"}
    }
  })

  module.job_menu:on('ready', print("Job Menu Ready"))

  module.job_menu:on('item.click', module.jobItemClicked)
end

module.jobItemClicked = function(item, index)

  print("Item: ".. item .. "\nIndex: " .. index)

  local closestDistance, closestPlayer = ESX.Game.GetClosestPlayer()

  if closestDistance < 5 and closestPlayer ~= 1 then

    if item.name == "search" then
      module.closeJobMenu()

      request('job-police:GetPlayerInventory', function(inventory)

        local elements = {}

        for k,v in pairs(inventory) do
          element = {
            name = tostring(k),
            label = tostring(v.label),
            type = "button"
          }

          table.insert( elements, element )
        end

        module.openSearchMenu( elements )

      end, closestPlayer)
    end

    if item.name == "cuff" then
      module.closeJobMenu()
      emit('job-police:cuff', closestPlayer)
    end

    if item.name == "drag" then
      module.closeJobMenu()
      emit('job-police:drag', closestPlayer)
    end

    if item.name == "jail" then
      module.closeJobMenu()
      -- Jail
    end

    if item.name == "fine" then
      module.closeJobMenu()
      module.openFineMenu()
    end

    if item.name == "put_vehicle" then
      module.closeJobMenu()

      emit('job-police:putInVehicle', closestPlayer)
    end

    if item.name == "exit" then
      module.closeJobMenu()
    end
  end

end

module.closeJobMenu = function()
  job_menu:destroy()
end

-- Search Menu
module.openSearchMenu = function( options )

  local elements = {}
  local elements = options

  table.insert(elements, {
    name = "back", label = "Back", type = "button"
  })

  module.search_menu = Menu('search_menu', {
    title = "Search player",
    float = "top|left",
    items = elements
  })

  module.job_menu:on('ready', print("Search Menu Ready"))

  module.job_menu:on('item.click', module.searchItemClicked)
end

module.searchItemClicked = function(item, index)

  -- Items found logic (Confiscate)

  if item.name == "back" then
    module.closeSearchMenu()
    module.openJobMenu()
  end

end

module.closeSearchMenu = function()
  search_menu:destroy()
end

-- Fine Menu
module.openFineMenu = function()

  module.fine_menu = Menu('fine_menu', {
    title = "Fines",
    float = "top|left",
    items = {
      {name = "category_0", label = "Vehicle Offences", type = "button"},
      {name = "category_1", label = "Minor Offences", type = "button"},
      {name = "category_2", label = "Medium Offences", type = "button"},
      {name = "category_3", label = "Major Offences", type = "button"},
      {name = "back",       label = "Back", type = "button"}
    }
  })

  module.fine_menu:on('ready', print("Fine Menu Ready"))

  module.fine_menu:on('item.click', module.fineItemClicked)
end

module.fineItemClicked = function(item, index)

  if item.name == "category_0" then
    module.closeFineMenu()
    emit('job-police:fine', 0)
  end

  if item.name == "category_1" then
    module.closeFineMenu()
    emit('job-police:fine', 1)
  end

  if item.name == "category_2" then
    module.closeFineMenu()
    emit('job-police:fine', 2)
  end

  if item.name == "category_3" then
    module.closeFineMenu()
    emit('job-police:fine', 3)
  end

  if item.name == "back" then
    module.closeFineMenu()
    module.openJobMenu()
  end
end

module.closeFineMenu = function()
  fine_menu:destroy()
end

-- Display Fines Selected
module.displayFines = function(fines)

  chosen_fines = {}

  for _,v in ipairs(fines) do
    for i = 1, #v, 1 do
      table.insert(chosen_fines, {
        name = i,
        label = v[i],
        type = "button"
      })
    end
  end

  table.insert(chosen_fines, {
    name = "back",
    label = "Back",
    type = "button"
  })

  module.fines_list = Menu('fines_list', {
    title = "Fines list",
    float = "top|left",
    items = chosen_fines
  })

  module.fines_list:on('ready', print("Fines List Menu Ready"))

  module.fines_list:on('item.click', module.finesListItemClicked)
end

module.finesListItemClicked = function(item, index)
  if item.name = "back" then
    module.closeFinesList()
    module.openFineMenu()
  end

  local closestDistance, closestPlayer = ESX.Game.GetClosestPlayer()

  if closestDistance < 5 and closestPlayer ~= -1 then
    for k,v in chosen_fines do
      if v.name == item.label then
        emitServer("job-police:giveFine", k, v.price, closestPlayer)
      end
    end
  end

end

module.closeFinesList = function()
  fines_list:destroy()
end

-- Cuffed Disable Controls
module.cuffedControls = function()
  local playerPed = PlayerPedId()

  DisableControlAction(0, 1, true) -- Disable pan
  DisableControlAction(0, 2, true) -- Disable tilt
  DisableControlAction(0, 24, true) -- Attack
  DisableControlAction(0, 257, true) -- Attack 2
  DisableControlAction(0, 25, true) -- Aim
  DisableControlAction(0, 263, true) -- Melee Attack 1
  DisableControlAction(0, 32, true) -- W
  DisableControlAction(0, 34, true) -- A
  DisableControlAction(0, 31, true) -- S
  DisableControlAction(0, 30, true) -- D

  DisableControlAction(0, 45, true) -- Reload
  DisableControlAction(0, 22, true) -- Jump
  DisableControlAction(0, 44, true) -- Cover
  DisableControlAction(0, 37, true) -- Select Weapon
  DisableControlAction(0, 23, true) -- Also 'enter'?

  DisableControlAction(0, 288,  true) -- Disable phone
  DisableControlAction(0, 289, true) -- Inventory
  DisableControlAction(0, 170, true) -- Animations
  DisableControlAction(0, 167, true) -- Job

  DisableControlAction(0, 0, true) -- Disable changing view
  DisableControlAction(0, 26, true) -- Disable looking behind
  DisableControlAction(0, 73, true) -- Disable clearing animation
  DisableControlAction(2, 199, true) -- Disable pause screen

  DisableControlAction(0, 59, true) -- Disable steering in vehicle
  DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
  DisableControlAction(0, 72, true) -- Disable reversing in vehicle

  DisableControlAction(2, 36, true) -- Disable going stealth

  DisableControlAction(0, 47, true)  -- Disable weapon
  DisableControlAction(0, 264, true) -- Disable melee
  DisableControlAction(0, 257, true) -- Disable melee
  DisableControlAction(0, 140, true) -- Disable melee
  DisableControlAction(0, 141, true) -- Disable melee
  DisableControlAction(0, 142, true) -- Disable melee
  DisableControlAction(0, 143, true) -- Disable melee
  DisableControlAction(0, 75, true)  -- Disable exit vehicle
  DisableControlAction(27, 75, true) -- Disable exit vehicle

  if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
    ESX.Streaming.RequestAnimDict('mp_arresting', function()
      TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
    end)
  end
end