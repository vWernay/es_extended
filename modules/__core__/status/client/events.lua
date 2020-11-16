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
  if low then
    print("statuslow")
    module.StatusLow()
  end

  if dying then
    print("dying")
    module.StatusDying()
  end

  if drunk then
    print("drunk")
    module.Drunk(drunk)
  end

  if drugs > 0 then
    print("drugs")
    module.Drugs(drugs)
  end

  if stress > 0 then
    print(tostring(stress))
    print("stress")
    module.Stress(stress)
  end
end)

onServer('esx:status:damagePlayer', function()
  module.DamagePlayer()
end)

on('esx:skin:loaded', function()
  emitServer('esx:status:initialize')
  module.Init()
end)