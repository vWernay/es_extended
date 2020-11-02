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

ESX.SetInterval(300, function()
  if IsPauseMenuActive() and not module.isPaused then
    module.isPaused = true
    -- Hide HUD
  elseif not IsPauseMenuActive() and module.isPaused then
    module.isPaused = false
    -- Allow HUD To Be Shown
  end
end)

StatusTest = {
  {
    id = "hunger",
    color = "red",
    value = 100,
    icon = "fa-car",
    iconType = "fontawesome"
  },
  {
    id = "hunger",
    color = "blue",
    value = 100,
    icon = "fa-car",
    iconType = "fontawesome"
  }
}

ESX.SetInterval(Config.Modules.Status.UpdateInterval * 1000, function() -- update with 1000
  if module.StatusReady == true then
    module.UpdateStatusThroughTick()
  end
end)
