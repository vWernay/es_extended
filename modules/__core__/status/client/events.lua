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

on('status:registerStatus', function(name, default, color, visible, tickCallback)
	local status = module.CreateStatus(name, default, color, visible, tickCallback)
	table.insert(module.Status, status)
end)

on('status:unregisterStatus', function(name)
	for k,v in ipairs(module.Status) do
		if v.name == name then
			table.remove(module.Status, k)
			break
		end
	end
end)

on('status:load', function(status)
  for i=1, #module.Status, 1 do
    for j=1, #status, 1 do
      if module.Status[i].name == status[j].name then
          module.Status[i].set(status[j].val)
      end
    end
  end

  ESX.SetInterval(module.Config.TickTime, function()
    for i=1, #module.Status, 1 do
      module.Status[i].onTick()
    end

    SendNUIMessage({
      update = true,
      status = module.GetStatusData()
    })

    emit('status:onTick', module.GetStatusData(true))
  end)
end)

on('status:set', function(name, val)
	for i=1, #module.Status, 1 do
		if module.Status[i].name == name then
			module.Status[i].set(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = module.GetStatusData()
	})

	emitServer('status:update', module.GetStatusData(true))
end)

on('status:add', function(name, val)
	for i=1, #module.Status, 1 do
		if module.Status[i].name == name then
			module.Status[i].add(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = module.GetStatusData()
	})

	emitServer('status:update', module.GetStatusData(true))
end)

on('status:remove', function(name, val)
	for i=1, #module.Status, 1 do
		if module.Status[i].name == name then
			module.Status[i].remove(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = module.GetStatusData()
	})

	emitServer('status:update', module.GetStatusData(true))
end)

on('status:getStatus', function(name, cb)
	for i=1, #module.Status, 1 do
		if module.Status[i].name == name then
			cb(module.Status[i])
			return
		end
	end
end)

on('status:setDisplay', function(val)
	SendNUIMessage({
		setDisplay = true,
		display    = val
	})
end)