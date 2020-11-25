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
  emitServer('esx:status:setStatus', statusName, value)
end)

onServer('esx:status:updateStatus', function(statuses)
  module.UpdateStatus(statuses)
end)

onServer('esx:status:statCheck', function(low, dying, drunk, drugs, stress)
  if dying then
    module.StatusDying()
  elseif low then
    module.StatusLow()
  elseif drunk == 0 and drugs == 0 and stress == 0 then
    module.StatusGood()
  else
    -- Only active if player is not low status or dying status
    -- Prioritize Stress > Drunk > Drugs
    if (stress > 0 and stress == drunk) or (stress > 0 and stress == drugs) then
      module.Stress(stress)
    elseif stress > 0 and stress > drugs and stress > drunk then
      module.Stress(stress)
    elseif drunk > 0 and drunk == drugs then
      module.Drunk(drunk)
    elseif drunk > 0 and drunk > drugs and drunk > stress then
      module.Drunk(drunk)
    elseif drugs > 0 and drugs > stress and drugs > drunk then
      module.Drugs(drugs)
    end
  end
end)

onServer('esx:status:damagePlayer', function()
  module.DamagePlayer()
end)

on('esx:skin:loaded', function()
  emitServer('esx:status:initialize')
  module.Init()
end)