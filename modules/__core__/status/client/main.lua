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


ESX.SetInterval(1, function()
    if module.Injured then
        -- DisableControlAction(0,21,true)
        SetPedMovementClipset(GetPlayerPed(-1), "move_m@injured", true)
    else
        Wait(999)
    end
end)