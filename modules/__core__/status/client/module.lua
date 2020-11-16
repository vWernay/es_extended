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

M('ui.hud')
module.Ready, module.Frame, module.isPaused, module.Sick = false, nil, false, false

module.StatusDying = function()
  -- INSERT YOUR CRAZY SHIT HERE
  ApplyDamageToPed(PlayerPedId(), 10, false)
end

module.StatusLow = function()
-- INSERT YOUR CRAZY SHIT HERE
end

module.Drunk = function(value)
  local drunkDriving = false
  local bool         = false
  local fade         = 0
  local clipset      = nil
  local fallChance   = 0
  local modifier     = nil
  local sickChance   = 0
  local veh          = nil
  local index = GetTimecycleModifierIndex()

  if value >= 0 and value <= 9 then
    module.Init() -- Clears everything
  elseif value >= 10 and value <= 24 then
    bool         = true
    fade         = 0
    clipset      = "MOVE_M@BUZZED"
    fallChance   = 0
    modifier     = "MP_corona_heist_DOF"
    sickChance   = 0
  elseif value >= 25 and value <= 49 then
    bool         = true
    fade         = 0
    clipset      = "MOVE_M@DRUNK@SLIGHTLYDRUNK"
    fallChance   = math.random(0,100)
    modifier     = "MP_corona_heist_DOF"
    sickChance   = math.random(0,100)
  elseif value >= 50 and value <= 75 then
    bool         = true
    fade         = 0
    clipset      = "MOVE_M@DRUNK@A"
    fallChance   = math.random(10,100)
    modifier     = "MP_corona_heist_DOF"
    sickChance   = math.random(10,100)
  elseif value >= 76 and value <= 89 then 
    bool         = true
    fade         = 0
    clipset      = "MOVE_M@DRUNK@VERYDRUNK"
    fallChance   = math.random(25,100)
    modifier     = "BlackOut"
    sickChance   = math.random(20,100)
  elseif value >= 90 and value <= 100 then
    bool         = true
    fade         = 1000
    clipset      = "MOVE_M@DRUNK@VERYDRUNK"
    fallChance   = math.random(35,100)
    modifier     = "BlackOut"
    sickChance   = math.random(30,100)
  end
  
  module.IsDrunk(bool, fade, modifier)

  if clipset then
    module.DrunkEffects(clipset, fallChance, sickChance)
  end

  if value > 25 and module.Sick == true then
    if IsPedInVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId()), false) then
      veh = GetVehiclePedIsIn(PlayerPedId())

      if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
        drunkDriving = true
      end
    end
  else
    drunkDriving = false
  end

  if drunkDriving then
    module.DrunkDriving(veh)
  end
end

module.Drugs = function(value)
-- INSERT YOUR CRAZY SHIT HERE
end

module.Stress = function(value)
-- INSERT YOUR CRAZY SHIT HERE
end

module.DrunkEffects = function(clipSet,fallChance,sickChance)
  if not HasAnimSetLoaded(clipSet) then
    RequestAnimSet(clipSet)
    while not HasAnimSetLoaded(clipSet) do
      Citizen.Wait(0)
    end
  end
  SetPedMovementClipset(PlayerPedId(), clipSet, 0.2)

  if sickChance >= 80 then
    module.Sick = true
    local dict = "oddjobs@taxi@tie"
    local animationName = "vomit_outside"
    local pukeLength = 8000
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
      Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), dict, animationName, 8.0, 8.0, pukeLength, 49, 0, false, false, false)
    Wait(pukeLength)
    StopAnimTask(PlayerPedId(), dict, animationName, 1.0)
    ApplyDamageToPed(PlayerPedId(), 1, false)
  else
    module.Sick = false
  end

  local fallTime = 2 * 1000 -- 2 seconds

  if fallChance >= 75 and not module.Sick then
    if not IsPedInVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId()), false) then
      SetPedToRagdoll(PlayerPedId(), fallTime, fallTime, 0, 0, 0, 0)
      DisableAllControlActions(0)
      ApplyDamageToPed(PlayerPedId(), 1, false)
      Wait(fallTime)
      EnableAllControlActions(0)
    end
  end
end
  
module.IsDrunk = function(bool, fade, modifier)
  SetPedConfigFlag(PlayerPedId(), 100, bool)
  SetPedIsDrunk(PlayerPedId(), bool) 
  if index ~= modifier then
    DoScreenFadeOut(fade)
    Wait(fade)
    SetTimecycleModifier(modifier)
    DoScreenFadeIn(fade)
  end
  if fade > 0 then
    DoScreenFadeOut(fade)
    Wait(fade)
    DoScreenFadeIn(fade)
  end
end

module.DrunkDriving = function(veh)
  local duration         = math.random(800,1500)
  local randomDrunkEvent = module.DrunkVehicleAction()
  TaskVehicleTempAction(driver, veh, randomDrunkEvent.action, randomDrunkEvent.duration)
end

module.DrunkVehicleAction = function()
  local generateRandomDrunkDrivingEvent = math.random(1, #Config.Modules.Status.RandomEvents)
	return Config.Modules.Status.RandomEvents[generateRandomDrunkDrivingEvent]
end

module.UpdateStatus = function(statuses)
  if statuses then
    local Statuses = {}
    local existingStatuses = {}

    for k,v in pairs(Config.Modules.Status.StatusIndex) do
      if k then
        if v then
          if not existingStatuses[v] then
            existingStatuses[v] = v
            if statuses[v]["fadeType"] == "desc" then
              if statuses[v]["value"] < 50 or statuses[v]["value"] == 75 or statuses[v]["value"] == 100 then
                table.insert(Statuses, statuses[v])
              end
            elseif statuses[v]["fadeType"] == "asc" then
              if statuses[v]["value"] > 0 then
                table.insert(Statuses, statuses[v])
              end
            end
          end
        end
      end
    end

    module.Frame:postMessage({
      app = "STATUS",
      method = "setStatus",
      data = Statuses
    })
  end
end

module.Frame = Frame('status', 'nui://' .. __RESOURCE__ .. '/modules/__core__/status/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
  emit('status:ready')
end)

module.Init = function()
  module.IsDrunk(false, 0)
  ResetPedMovementClipset(PlayerPedId(), 0)
  ClearTimecycleModifier()
end
