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

module.CreateStatus = function(name, color, iconType, icon, val, fadeType)
  if not module.Status[name] then
    module.Status[name] = {}

    module.Status[name]["id"] = name
    module.Status[name]["color"] = color
    module.Status[name]["value"] = val
    module.Status[name]["icon"] = icon
    module.Status[name]["iconType"] = iconType
    module.Status[name]["fadeType"] = fadeType
  end
end



module.SetStatus = function(statusName, value)
  local Statuses = {}
  local existingStatuses = {}

  if module.Status then
    for k,v in pairs(Config.Modules.Status.StatusIndex) do
      if k then
        if tostring(v) == tostring(statusName) then
          if module.Status[v] then
            if module.Status[v]["value"] then
              module.Status[v]["value"] = value

              if not existingStatuses[v] then
                existingStatuses[v] = value
                table.insert(Statuses, module.Status[v])
              end
            end
          end
        else
          if module.Status[v] then
            if module.Status[v]["value"] then
              if not existingStatuses[v] then
                existingStatuses[v] = value
                if module.Status[v]["fadeType"] == "desc" then
                  if module.HasValue(module.Status[v]["value"]) then
                    print(module.Status[v]["id"] .. " | " .. module.Status[v]["value"])
                    table.insert(Statuses, module.Status[v])
                  end
                elseif module.Status[v]["fadeType"] == "asc" then
                  if module.Status[v]["value"] > 0 then
                    table.insert(Statuses, module.Status[v])
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  emitServer('status:updateStatus', module.Status)

  module.Frame:postMessage({
    app = "STATUS",
    method = "setStatus",
    data = Statuses
  })
end

module.HasValue = function(val)
  for k,v in ipairs(Config.Modules.Status.NotificationValues) do
    if tonumber(v) == tonumber(val) then
      print("value found " .. v)
      return true
    end
  end
  return false
end

module.UpdateStatusThroughTick = function()
  local Statuses = {}
  local existingStatuses = {}

  if module.Status then
    for k,v in pairs(Config.Modules.Status.StatusIndex) do
      if k then
        if module.Status[v] then
          if module.Status[v]["value"] then
            if module.Status[v]["value"] then
              if module.Status[v]["value"] > 0 then
                module.Status[v]["value"] = module.Status[v]["value"] - 1
              end
            end

            if v then
              if not existingStatuses[v] then
                existingStatuses[v] = v
                if module.Status[v]["fadeType"] == "desc" then
                  if module.HasValue(module.Status[v]["value"]) then
                    print(module.Status[v]["id"] .. " | " .. module.Status[v]["value"])
                    table.insert(Statuses, module.Status[v])
                  end
                elseif module.Status[v]["fadeType"] == "asc" then
                  if module.Status[v]["value"] > 0 then
                    table.insert(Statuses, module.Status[v])
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  emitServer('status:updateStatus', module.Status)

  module.Frame:postMessage({
    app = "STATUS",
    method = "setStatus",
    data = Statuses
  })
end

module.UpdateStatusWithoutTick = function()
  local Statuses = {}
  local existingStatuses = {}
  local index = 0

  if module.Status then
    for k,v in pairs(Config.Modules.Status.StatusIndex) do
      if k then
        if module.Status[v] then
          if module.Status[v]["value"] then

            if v then
              if not existingStatuses[v] then
                existingStatuses[v] = v
                if module.Status[v]["fadeType"] == "desc" then
                  if module.HasValue(module.Status[v]["value"]) then
                    print(module.Status[v]["id"] .. " | " .. module.Status[v]["value"])
                    table.insert(Statuses, module.Status[v])
                  end
                elseif module.Status[v]["fadeType"] == "asc" then
                  if module.Status[v]["value"] > 0 then
                    table.insert(Statuses, module.Status[v])
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  emitServer('status:updateStatus', module.Status)

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
