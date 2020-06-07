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

local isCuffed = false
local isDragged = false
local controlsDisabled = false

handcuffTimer = {}

--[[

    TO DO LIST:

        => Blips (seperate module)
        => Markers (seperate module)
        => Clockroom
        => Armoury
        => Vehicle Handlers
        => Vehicle Interactions
        => Vehicle Lookup
        => Object Spawner (do we have a handler for that?)
        => Boss Menu
        => Identity Card + Licenses (see v1)
        => Unpaid bills
        => Door locking system (seperate module)

]]--

on('playerSpawned', function(spawn)
    module.uncuffPlayer()

    --emitServer('job-police:spawn')
end)

on('job-police:openpolicemenu', function()
    module.openJobMenu()
end)

on('job-police:closepolicemenu', function()
    module.closeJobMenu()
end)

on('job-police:cuff', function()
    local cuffed_loop

    isCuffed = not isCuffed

    if isCuffed then
        module.cuffPlayer()

        if not controlsDisabled then
            controlsDisabled = true

            cuffed_loop = ESX.SetTick(function()
                module.cuffedControls()
            end)
        end
    else
        module.uncuffPlayer()
        ESX.ClearTick(cuffed_loop)
        controlsDisabled = false
    end
end)

on('job-police:drag', function(target)
    local drag_loop
    local playerPed = PlayerPedId()

    isDragged = not isDragged

    if isCuffed and isDragged then

        local wasDragged = false

        drag_loop = ESX.SetTick(function()

            local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                wasDragged = true
            end
        end)

    elseif isCuffed and wasDragged and not isDragged then
        wasDragged = false
        DetachEntity(playerPed, true, false)
        ESX.ClearTick(drag_loop)

    else
        ESX.ShowNotification("Target is not cuffed!", "Police Action", 10000)
    end
end)

on('job-police:jail', function()
    -- Jail
end)

on('job-police:fine', function(category)

    local result = {}

    local fines = module.getFines()

    for k,v in ipairs(fines) do
        if v.category == category then
            table.insert( result, {v.category = v.fines} )
        end
    end

    module.displayFines(result)
end)

on('job-police:putInVehicle', function()
    if isCuffed then
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if IsAnyVehicleNearPoint(coords, 5.0) then
			local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

			if DoesEntityExist(vehicle) then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

				for i=maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end

				if freeSeat then
					TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
					isDragged = false
				end
			end
		end
	end
end)

on('onResourceStop', function(resource)

    if resource == GetCurrentResourceName() then

        emit('job-police:uncuff')

        if Config.EnableESXService then
            print("Disabling police service")
            --emit('service:disableService', 'police')
        end

        if Config.EnableHandcuffTimer and handcuffTimer.active then
            ESX.ClearTimeout(handcuffTimer.active)
        end

    end

end)

