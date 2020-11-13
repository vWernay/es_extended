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
module.Ready, module.Frame, module.isPaused = false, nil, false

module.DamagePlayer = function()
  ApplyDamageToPed(PlayerPedId(), 10, false)
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
