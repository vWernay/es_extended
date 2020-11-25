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

local utils = M('utils')

module.DyingActive, module.LowActive, module.StressActive, module.DrunkActive, module.DrugsActive = false, false, false, false, false
module.Ready           = false
module.Frame           = nil
module.isPaused        = false
module.Sick            = false

module.StatusGood = function()
  if module.DyingActive then
    module.DyingActive    = false
    module.Injured        = false
    ResetPedMovementClipset(PlayerPedId())

    utils.game.BreakSwingingLoopModifier()

    Wait(50)
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
  elseif module.LowActive or module.StressActive or module.DrunkActive or module.DrugsActive then
    module.DyingActive  = false
    module.LowActive    = false
    module.StressActive = false
    module.DrunkActive  = false
    module.DrugsActive  = false

    utils.game.BreakLoopModifier()

    Wait(50)

    ClearTimecycleModifier()
  end
end

module.StatusDying = function()
  if not module.DyingActive then
    if module.LowActive then
      module.LowActive = false
      utils.game.BreakLoopModifier()
      Wait(50)
      ClearTimecycleModifier()
    end

    module.DyingActive    = true
    module.Injured        = true
    RequestAnimSet("move_m@injured")
    Wait(100)
    utils.game.SwingingLoopModifier("dying", "damage", 40, 0.02, 0.25, 0.75)
  end

  if math.random(0,100) > 70 then
    local shakeIntensity = math.random(1,10) * 0.1
    ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", shakeIntensity)
  
    local time = math.random(1500,3500)
    SetPedToRagdoll(PlayerPedId(), time, time, 3, 0, 0, 0)
    DisableAllControlActions(0)
    Wait(time)
    EnableAllControlActions(0)
    -- Make player stumble smoothly but not fall down
  end

  ApplyDamageToPed(PlayerPedId(), 10, false)
end

module.StatusLow = function()
  if module.DyingActive then
    module.DyingActive    = false
    module.Injured        = false
    ResetPedMovementClipset(PlayerPedId())
    utils.game.BreakSwingingLoopModifier()
    Wait(50)
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
  end

  if not module.LowActive then
    module.LowActive = true
    Wait(100)
    utils.game.LoopModifier("dying", 40, 0.02, 0.0, 0.6)
  end

  if math.random(0,100) > 75 then
    utils.game.DoAnimation("anim@mp_player_intupperface_palm","idle_a",4000,49)
  end
end

module.Drunk = function(value)
  local drunkDriving = false
  local bool         = false
  local clipset      = nil
  local fallChance   = 0
  local modifier     = nil
  local sickChance   = 0
  local veh          = nil

  if value >= 0 and value <= 9 then
    module.Init() -- Clears everything
  elseif value >= 10 and value <= 24 then
    module.DrunkActive = true
    bool         = true
    clipset      = "MOVE_M@BUZZED"
    fallChance   = 0
    modifier     = "MP_corona_heist_DOF"
    sickChance   = 0

    module.IsDrunk(clipset, bool, modifier)
    module.DrunkEffects(fallChance, sickChance)
    -- module.DrunkMovement(clipset)
  elseif value >= 25 and value <= 49 then
    module.DrunkActive = true
    bool         = true
    clipset      = "MOVE_M@DRUNK@SLIGHTLYDRUNK"
    fallChance   = math.random(0,100)
    modifier     = "MP_corona_heist_DOF"
    sickChance   = math.random(0,100)

    module.IsDrunk(clipset, bool, modifier)
    module.DrunkEffects(fallChance, sickChance)
    -- module.DrunkMovement(clipset)
  elseif value >= 50 and value <= 75 then
    module.DrunkActive = true
    bool         = true
    clipset      = "MOVE_M@DRUNK@A"
    fallChance   = math.random(10,100)
    modifier     = "MP_corona_heist_DOF"
    sickChance   = math.random(10,100)

    module.IsDrunk(clipset, bool, modifier)
    module.DrunkEffects(fallChance, sickChance)
    -- module.DrunkMovement(clipset)
  elseif value >= 76 and value <= 89 then
    module.DrunkActive = true
    bool         = true
    clipset      = "MOVE_M@DRUNK@VERYDRUNK"
    fallChance   = math.random(25,100)
    modifier     = "BlackOut"
    sickChance   = math.random(20,100)

    module.IsDrunk(clipset, bool, modifier)
    module.DrunkEffects(fallChance, sickChance)
    -- module.DrunkMovement(clipset)
  elseif value >= 90 and value <= 100 then
    module.DrunkActive = true
    bool         = true
    clipset      = "MOVE_M@DRUNK@VERYDRUNK"
    fallChance   = math.random(35,100)
    modifier     = "BlackOut"
    sickChance   = math.random(30,100)

    module.IsDrunk(clipset, bool, modifier)
    module.DrunkEffects(fallChance, sickChance)
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

module.DrunkEffects = function(fallChance,sickChance)
  if sickChance >= 80 then
    module.Sick = true
    utils.game.DoAnimation("oddjobs@taxi@tie","vomit_outside",8000,49)
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

  module.IsMoving = true
end

module.IsDrunk = function(clipset, bool, modifier)
  SetPedConfigFlag(PlayerPedId(), 100, bool)
  SetPedIsDrunk(PlayerPedId(), bool)

  if module.CurrentModifier ~= modifier then
    if module.CurrentModifier ~= 0 then
      utils.game.FadeOutModifier()
    end

    module.CurrentModifier = modifier
    utils.game.FadeInModifier(modifier, clipset)
  end
end

module.DrunkDriving = function(veh)
  local generateRandomDrunkDrivingEvent = math.random(1, #Config.Modules.Status.RandomEvents)
  local randomDrunkEvent                = Config.Modules.Status.RandomEvents[generateRandomDrunkDrivingEvent]

  TaskVehicleTempAction(driver, veh, randomDrunkEvent.action, randomDrunkEvent.duration)
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
  module.DyingActive  = false
  module.LowActive    = false
  module.StressActive = false
  module.DrunkActive  = false
  module.DrugsActive  = false
  module.DrunkActive  = false
  module.Injured      = false

  ClearTimecycleModifier()
  ClearExtraTimecycleModifier()
  ResetPedMovementClipset(PlayerPedId())
end

-- module.FadeInModifier = function(modifier, clipset)
--   SetTimecycleModifierStrength(0.0)
--   SetTimecycleModifier(modifier)
--   SetTimecycleModifierStrength(0.0)

--   Citizen.CreateThread(function()
--     while true do
--       if tonumber(module.CurrentStrength) < 1.0 and module.DrunkActive and module.FadeIn then
--         module.CurrentStrength = module.CurrentStrength + 0.001
--         SetTimecycleModifierStrength(module.CurrentStrength)

--         if tostring(module.CurrentStrength * 10) == tostring(5.0) then
--           if clipset then
--             if not HasAnimSetLoaded(clipset) then
--               RequestAnimSet(clipset)
      
--               while not HasAnimSetLoaded(clipset) do
--                 Wait(0)
--               end
--             end

--             local randomAnimation = math.random(0,100)

--             if randomAnimation <= 50 then
--               dict = "anim@mp_player_intupperface_palm"
--               animationName = "idle_a"
--               animationLength = 4000
--               flag = 49
--             elseif randomAnimation > 50 then
--               dict = "missminuteman_1ig_2"
--               animationName = "tasered_2"
--               animationLength = 4000
--               flag = 49
--             end
            
--             utils.game.DoAnimation(dict,animationName,animationLength,flag)
--             SetPedMovementClipset(PlayerPedId(), clipset, 0.2)
--           end
--         else
--           Wait(10)
--         end
--       else
--         break
--       end
--     end
--   end)
-- end

-- module.FadeOutModifier = function()
--   Citizen.CreateThread(function()
--     while true do
--       if tonumber(module.CurrentStrength) > 0 then
--         module.CurrentStrength = module.CurrentStrength - 0.001
--         SetTimecycleModifierStrength(module.CurrentStrength)
--         Wait(10)
--       else
--         module.FadedOut = true
--         ClearTimecycleModifier()
--         break
--       end
--     end
--   end)
-- end