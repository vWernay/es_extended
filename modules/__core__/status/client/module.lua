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
module.Ready, module.Frame, module.Status, module.StatusReady, module.isPaused = false, nil, {}, false, false

module.CreateStatus = function(name, color, iconType, icon, val)
  if not module.Status[name] then
    module.Status[name] = {}

    module.Status[name]["id"] = name
    module.Status[name]["color"] = color
    module.Status[name]["value"] = val
    module.Status[name]["icon"] = icon
    module.Status[name]["iconType"] = iconType
  end
end

module.SetStatus = function(statusName, value)
  if module.Status then
    local Statuses = {}
    local existingStatuses = {}

    if module.Status[statusName] then
      if module.Status[statusName]["value"] then
        module.Status[statusName]["value"] = value
      end
    end

    for k,v in pairs(module.Status) do
      if k then
        if module.Status[k] then
          if module.Status[k]["value"] then

            if v then
              if not existingStatuses[k] then
                existingStatuses[k] = v
                table.insert(Statuses, v)
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

module.UpdateStatusThroughTick = function()
  local Statuses = {}
  local existingStatuses = {}

  if module.Status then
    for k,v in pairs(module.Status) do
      if k then
        if module.Status[k] then
          if module.Status[k]["value"] then
            if module.Status[k]["value"] then
              if module.Status[k]["value"] > 0 then
                module.Status[k]["value"] = module.Status[k]["value"] - 1
              end
            end

            if v then
              if not existingStatuses[k] then
                existingStatuses[k] = v
                table.insert(Statuses, v)
              end
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

module.UpdateStatusWithoutTick = function()
  local Statuses = {}
  local existingStatuses = {}

  if module.Status then
    for k,v in pairs(module.Status) do
      if k then
        if module.Status[k] then
          if module.Status[k]["value"] then

            if v then
              if not existingStatuses[k] then
                existingStatuses[k] = v
                table.insert(Statuses, v)
              end
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

module.Frame = Frame('status', 'nui://' .. __RESOURCE__ .. '/modules/__core__/status/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
  emit('status:ready')
end)
