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

local Input = M('input')
local HUD   = M('game.hud')
local utils = M("utils")

module.Init()

ESX.SetInterval(250, function()

  if not module.isInShopMenu then
    if utils.game.isPlayerInZone(module.Config.VehicleShopZones) then
        if not module.inMarker then
            module.inMarker = true
            emit('vehicleshop:enteredZone')
        end
    else
        if module.inMarker then
            module.inMarker = false
            emit('vehicleshop:exitedZone')
        end
    end
  end

end)

ESX.SetInterval(0, function()

  if module.inMarker or module.inSellMarker then
    Input.DisableControl(Input.Groups.MOVE, Input.Controls.SPRINT)
    Input.DisableControl(Input.Groups.MOVE, Input.Controls.JUMP)
    DisableControlAction(0,21,true)
    DisableControlAction(0,22,true)
    DisableControlAction(0,25,true)  -- disable aim
    DisableControlAction(0,47,true)  -- disable weapon
    DisableControlAction(0,58,true)  -- disable weapon
    DisableControlAction(0,263,true) -- disable melee
    DisableControlAction(0,264,true) -- disable melee
    DisableControlAction(0,257,true) -- disable melee
    DisableControlAction(0,140,true) -- disable melee
    DisableControlAction(0,141,true) -- disable melee
    DisableControlAction(0,142,true) -- disable melee
    DisableControlAction(0,143,true) -- disable melee

    NetworkSetFriendlyFireOption(false)
    SetCanAttackFriendly(PlayerPedId(), false, false)

    if IsControlJustReleased(0, 38) and module.CurrentAction ~= nil then
      module.CurrentAction()
    end

    if module.isInShopMenu then
      DisableControlAction(0,51,true)
    end
  end

  if module.inTestDrive then
    if IsControlJustReleased(0, 51, true) then
      module.testDriveTime = 0
    end
  end

end)

-- ESX.SetInterval(0, function()

--   if module.inMarker and not module.isInShopMenu then
--     local coords = GetEntityCoords(PlayerPedId(), true)
--     utils.ui.draw3DText(coords.x, coords.y, coords.z, 0, 255, 0, 68, "In Zone")
--   elseif not module.inMarker and not module.isInShopMenu then
--     local coords = GetEntityCoords(PlayerPedId(), true)
--     utils.ui.draw3DText(coords.x, coords.y, coords.z, 255, 0, 0, 68, "Not In Zone")
--   end

-- end)