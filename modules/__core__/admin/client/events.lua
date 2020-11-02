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
local Input = M('input')

Input.On('pressed', Input.Groups.LOOK, Input.Controls.SCRIPTED_FLY_ZUP, function()
  if IsInputDisabled(2) then
    module.OpenMenu()
  end
end)

Input.On('released', Input.Groups.CELLPHONE_NAVIGATE, Input.Controls.FRONTEND_CANCEL, function()
  if module.CancelCurrentAction then
    module.CancelCurrentAction()
    module.CancelCurrentAction = nil
  end
end)

onServer('esx:admin:inPlayerCommand', function(...)
  module.OnSelfCommand(...)
end)
