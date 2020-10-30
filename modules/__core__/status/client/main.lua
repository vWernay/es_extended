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
  if module.IsPauseMenuActive() and not module.isPaused then
    module.isPaused = true
    emit('status:setDisplay', 0.0)
  elseif not IsPauseMenuActive() and module.isPaused then
    module.isPaused = false 
    emit('status:setDisplay', 0.5)
  end
end)

ESX.SetInterval(module.Config.UpdateInterval, function()
	emitServer('status:update', module.GetStatusData(true))
end)

ESX.SetInterval(1, function()
  module.Frame:postMessage({
    update = true,
    status = module.Status
  })
end)