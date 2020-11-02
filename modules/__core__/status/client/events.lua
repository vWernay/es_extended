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

onServer('status:setStatusCommand', function(statusName, value)
  module.SetStatus(statusName, value)
end)

on('esx:skin:loaded', function()
  module.CreateStatus("hunger", "orange", "fontawesome", "fa-car", 100)
  module.CreateStatus("thirst", "blue", "fontawesome", "fa-car", 80)
  module.StatusReady = true
  module.UpdateStatusWithoutTick()
end)