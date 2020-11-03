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

local Interact = M('interact')
local Input = M('input')
local utils = M('utils')
M('ui.menu')

module.MenuHiddenList = {}
module.CancelCurrentAction = nil
module.WeaponList = nil

module.OnSelfCommand = function(action, ...)
	module[action](...)
end

module.Init = function()
	request("esx:admin:isAuthorized", function(isAdmin)
		if isAdmin then
			local wList = utils.weapon.getAll()

			module.WeaponList = {}

			for i=1, #wList, 1 do
				if not wList[i].name:match("VEHICLE_(%S+)") then
					table.insert(module.WeaponList, wList[i])
				end
			end

			Input.RegisterControl(Input.Groups.LOOK, Input.Controls.SCRIPTED_FLY_ZUP)

			Input.RegisterControl(Input.Groups.CELLPHONE_NAVIGATE, Input.Controls.FRONTEND_CANCEL)
		end
	end)
end

module.TPTMarker = function(sourceId)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if DoesBlipExist(GetFirstBlipInfoId(8)) then
			local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
	
			for height = 1, 1000, 10 do
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
	
				local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], 2500.0)
	
				if foundGround then
					SetPedCoordsKeepVehicle(PlayerPedId(), vector3(waypointCoords["x"], waypointCoords["y"], zPos))
					break
				end
	
				Citizen.Wait(60)
			end

			utils.ui.showNotification(_U('admin_result_tp'))
		else
			utils.ui.showNotification(_U('admin_result_tptm'))
		end
	end, sourceId)
end

module.TPTPlayer = function(sourceId, playerId)
	request("esx:admin:isAuthorized", function(a)
		if a then	utils.game.teleport(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId))))	end
	end, sourceId)
end

module.SpawnVehicle = function(sourceId, vehicleName)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		local model = (type(vehicleName) == 'number' and vehicleName or GetHashKey(vehicleName))

		if IsModelInCdimage(model) then
			local playerPed = PlayerPedId()
			local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)

			utils.game.createVehicle(model, playerCoords, playerHeading, function(vehicle)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			end)
		else
			TriggerEvent('chat:addMessage', {args = {'^1SYSTEM', 'Invalid vehicle model.'}})
		end
	end, sourceId)
end

module.DeleteVehicle = function(sourceId, radius)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if IsPedInAnyVehicle(PlayerPedId(), true) then
			module.delVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
		else
			if radius and tonumber(radius) then
				local vehicles = utils.game.getVehiclesInArea(GetEntityCoords(PlayerPedId()), tonumber(radius) + 0.01)

				for k,entity in ipairs(vehicles) do
					if not IsPedAPlayer(GetPedInVehicleSeat(entity, -1)) and not IsPedAPlayer(GetPedInVehicleSeat(entity, 0)) then -- prevent delete with people inside.
						module.delVehicle(entity)
					end
				end
			end
		end
	end, sourceId)
end

module.delVehicle = function(entity)
	local hasOwner = false

	-- maybe deprecated, read vehicle module to se how works now
	-- local plate = GetVehicleNumberPlateText(entity)

	-- if plate then     -- uncomment this prevent vehicle with owners(players) deleted   |   (if you use 8 digits in plate, need other method to validate this)
	-- 	plate, _ = plate:gsub( "%s+", "" )
	-- 	if plate:len() == 6 then
	-- 		hasOwner = true
	-- 	end
	-- end

	local attempt = 0
	NetworkRequestControlOfEntity(entity)
	SetVehicleHasBeenOwnedByPlayer(entity, false)

	while not NetworkHasControlOfEntity(entity) and attempt < 150 and DoesEntityExist(entity) do
		Citizen.Wait(20)
		NetworkRequestControlOfEntity(entity)
		attempt = attempt + 1
	end

	if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) and not hasOwner then
		utils.game.deleteVehicle(entity)
	end
end

module.FreezeUnfreeze = function(sourceId, action)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if action == 'freeze' then
			FreezeEntityPosition(PlayerPedId(), true)
			SetEntityCollision(PlayerPedId(), false)
			SetPlayerInvincible(PlayerId(), true)
			utils.ui.showNotification(_U('admin_result_freeze'))
		elseif action == 'unfreeze' then
			FreezeEntityPosition(PlayerPedId(), false)
			SetEntityCollision(PlayerPedId(), true)
			SetPlayerInvincible(PlayerId(), false)
			utils.ui.showNotification(_U('admin_result_unfreeze'))
		end
	end, sourceId)
end

module.RevivePlayer = function(sourceId)
	if IsEntityDead(PlayerPedId()) then
		request("esx:admin:isAuthorized", function(a)
			if not a then return end

			NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId()), true, true, false)

			ClearPedBloodDamage(PlayerPedId())
			ClearPedLastDamageBone(PlayerPedId())
			ResetPedVisibleDamage(PlayerPedId())
			ClearPedLastWeaponDamage(PlayerPedId())
			RemoveParticleFxFromEntity(PlayerPedId())
			utils.ui.showNotification(_U('admin_result_revive'))
		end, sourceId)
	end
end

module.GetUserCoords = function(targetId)
	print(table.unpack(GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(targetId)))))
end

module.GetPlayerList = function(sourceId)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		for _, playerId in ipairs(GetActivePlayers()) do
			print(('Player %s with id %i is in the server'):format(GetPlayerName(playerId), playerId))
		end
	end, sourceId)
end

module.SpectatePlayer = function(sourceId, targetId)
	if module.CancelCurrentAction then
		return utils.ui.showNotification(_U('admin_result_current_active'))
	end

	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		local coords = GetEntityCoords(PlayerPedId())

		FreezeEntityPosition(PlayerPedId(), true)
		SetEntityVisible(PlayerPedId(), false, false)
		RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(targetId)))
		NetworkSetInSpectatorMode(1, targetId)

		module.CancelCurrentAction = function()
			Interact.StopHelpNotification()

			FreezeEntityPosition(PlayerPedId(), false)
			RequestCollisionAtCoord(coords)
			NetworkSetInSpectatorMode(0, targetId)
			SetEntityVisible(PlayerPedId(), true, true)

			utils.game.teleport(PlayerPedId(), coords)
		end

		Interact.ShowHelpNotification(_U('admin_result_spectate'))
	end, sourceId)
end

module.SetPlayerHealth = function(sourceId, health)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		if health == 100 then
			local tHealth = GetPedMaxHealth(PlayerPedId())
	
			SetEntityHealth(PlayerPedId(), tHealth)
		end

		if health == 0 then
			SetEntityHealth(PlayerPedId(), health)
		end

		utils.ui.showNotification(_U('admin_result_health'))
	end, sourceId)
end

module.SetPlayerArmor = function(sourceId, armor)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		SetPedArmour(PlayerPedId(), armor)
  	utils.ui.showNotification(_U('admin_result_armor'))
	end, sourceId)
end

module.GiveWeaponPlayer = function(sourceId, weaponName, ammo)
	request("esx:admin:isAuthorized", function(a)
		if not a then return end

		GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponName), ammo, false, true);
	end)
end

-- Admin Menu
module.OpenMenu = function()
	local menu = Menu('admin.main', {
    float = 'top|left',
    title = 'Administrator Menu',
    items = {
		{label = _U('menu_admin_player'), name = 'OpenPlayerMenu',  type = 'button'},
		{label = _U('menu_admin_vehicle'), name = 'OpenVehicleMenu',  type = 'button'},
		{label = _U('menu_admin_job'), name = 'OpenJobMenu',  type = 'button'},
		{label = _U('menu_admin_esx'), name = 'OpenEsxMenu',  type = 'button'},
		{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, false) then return end

		module[item.name](menu)
	end)
end

-- Player menu
module.OpenPlayerMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.player_menu', {
    float = 'top|left',
    title = 'Player Menu',
    items = {
		{label = _U('admin_command_tptm'), name = 'TPTMarkerMenu', type='button'},
		{label = _U('admin_command_tptp'), name = 'TPTPlayerMenu', type='button'},
		{label = _U('admin_command_revive'), name = 'ReviveMenu', type='button'},
		{label = _U('admin_command_health'), name = 'HealthMenu', type='button'},
		{label = _U('admin_command_armor'), name = 'ArmorMenu', type='button'},
		{label = _U('admin_command_set_weapon'), name = 'SetWeaponMenu', type='button'},
		{label = _U('admin_command_spectate_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SpectatePlayer', self = true, type = 'button', after = 'close'},
		-- {label = _U('admin:command_del_weapon'), name = 'DelWeaponMenu', type='button'},
		-- {label = _U('admin:command_kick'), name = 'KickPlayerMenu', type='button'},
		-- {label = _U('admin:command_ban'), name = 'BanPlayerMenu', type='button'},
		-- {label = _U('admin:command_unban'), name = 'UnBanPlayerMenu', type='button'},
		{label = _U('back'), name = 'back', type = 'button'},
		{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module[item.name](menu)
	end)
end

module.TPTMarkerMenu = function(m)
	module.HideMenu(m)
	
	local menu = Menu('admin.tptm_menu', {
		float = 'top|left',
		title = 'Teleport Menu (TPTM)',
		items = {
			{label = _U('admin_command_tptm'), name = 'TPTMarker', type='button'},
			{label = _U('menu_admin_oplayer'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'TPTMarker', self = false, type='button'},
			{label = _U('back'), name = 'back', type = 'button'},
			{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module.CloseMenu(false, menu)

		module[item.name]()
	end)
end

module.TPTPlayerMenu = function(m)
	module.HideMenu(m)
	
	local menu = Menu('admin.tptp_menu', {
		float = 'top|left',
		title = 'Teleport Menu (TPTP)',
		items = {
			{label = _U('admin_command_tptp'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'TPTPlayer', self = true, type='button'},
			{label = _U('admin_command_tptp_rev'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'TPTPlayer', self = false, type='button', arg = { GetPlayerServerId(PlayerId()) }},
			{label = _U('back'), name = 'back', type = 'button'},
			{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end
	end)
end

module.ReviveMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.revive_menu', {
		float = 'top|left',
		title = 'Revive Menu',
		items = {
			{label = _U('admin_command_revive'), name = 'RevivePlayer', type='button'},
			{label = _U('menu_admin_oplayer'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'RevivePlayer', self = false, type='button'},
			{label = _U('back'), name = 'back', type = 'button'},
			{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module.CloseMenu(false, menu)

		module[item.name]()
	end)
end

module.HealthMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.health_menu', {
		float = 'top|left',
		title = 'Health Menu',
		items = {
			{label = _U('admin_command_health'), name = 'SetPlayerHealth', type='button', arg = { 100 }},
			{label = _U('menu_admin_oplayer'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SetPlayerHealth', self = false, type='button', arg = { 100 }},
			{label = _U('admin_command_kill_player'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SetPlayerHealth', self = false, type='button', arg = { 0 }},
			{label = _U('back'), name = 'back', type = 'button'},
			{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end
		
		module.CloseMenu(false, menu)

		module[item.name](nil, table.unpack(item.arg))
	end)
end

module.ArmorMenu = function(m)
	module.HideMenu(m)

	local menu = Menu('admin.armor_menu', {
		float = 'top|left',
		title = 'Armor Menu',
		items = {
			{label = _U('admin_command_armor'), name = 'SetPlayerArmor', type='button', arg = { 100 }},
			{label = _U('menu_admin_oplayer'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'SetPlayerArmor', self = false, type='button', arg = { 100 }},
			{label = _U('back'), name = 'back', type = 'button'},
			{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		module.CloseMenu(false, menu)

		module[item.name](nil, table.unpack(item.arg))
	end)
end

module.SetWeaponMenu = function(m) -- maybe need optimization | weaponHashName 
	module.HideMenu(m)

	local weaponHashName = module.WeaponList[1].name

	local menu = Menu('admin.give_weapon_menu', {
		float = 'top|left',
		title = 'Give Weapon Menu',
		items = {
			{label = module.WeaponList[1].label .. '	' .. weaponHashName, type = 'slider', max = #module.WeaponList - 1},
			{label = _U('admin_command_set_weapon'), name = 'GiveWeaponPlayer', type='button'},
			{label = _U('menu_admin_oplayer'), playerList = true, source = GetPlayerServerId(PlayerId()), name = 'GiveWeaponPlayer', self = false, type='button', arg = { weaponHashName, 250 }},
			{label = _U('back'), name = 'back', type = 'button'},
			{label = _U('close'), name = 'close', type = 'button'}
	}})

	menu:on('item.change', function(item, prop, val)
		item.label = module.WeaponList[val+1].label .. '	' .. module.WeaponList[val+1].name
		weaponHashName = module.WeaponList[val+1].name
	end)

	menu:on('item.click', function(item, index)
		item.arg = {weaponHashName, 250}

		if module.BasicButtonsMenu(item, menu, m) then return end

		if item.type ~= "slider" then
			module.CloseMenu(false, menu)

			module[item.name](nil, weaponHashName, 250)
		end
	end)
end

-- Vehicle menu
-- module.OpenVehicleMenu = function(m)
-- 	module.HideMenu(m)

-- end

-- Reusable functions
module.UserListMenu = function(m, self, ...)
	module.HideMenu(m)

	elements = {
		{label = _U('back'), name = 'back', type = 'button'},
		{label = _U('close'), name = 'close', type = 'button'},
	}

	local playersActive = GetActivePlayers()

	if #playersActive > 0 then
		local ownID = GetPlayerIndex()

		table.insert(elements, {label = '', name = 'spacer', type='button'})

		for _, playerId in ipairs(playersActive) do

			if ownID ~= playerId then
				local playerSrc = GetPlayerServerId(playerId)
				table.insert(elements, {label = playerSrc ..' | '.. GetPlayerName(playerId), id = playerSrc, type = 'button'})
			end

			-- debug option.
			-- local playerSrc = GetPlayerServerId(playerId)
			-- table.insert(elements, {label = playerSrc ..' | '.. GetPlayerName(playerId), id = playerSrc, type = 'button'})
		end
	end

	local menu = Menu('admin.user_list_menu', {
		float = 'top|left',
		title = 'Player List',
		items = elements
	})

	local vArg = {...}

	menu:on('item.click', function(item)
		if module.BasicButtonsMenu(item, menu, m) then return end

		if self then
			module.OnSelfCommand(table.unpack(vArg), item.id)
		else
			emitServer('esx:admin:sendToPlayer', item.id, table.unpack(vArg))
		end
	end)
end

module.HideMenu = function(m)
	m:hide()
	table.insert(module.MenuHiddenList, m)
end

module.BasicButtonsMenu = function(item, menu, m)
	if item.name == 'spacer' then return true end

	if m then
		module.BackMenu(item, menu, m)
	end
		
	module.CloseMenu(item, menu)

	if item.name == 'close' or item.name == 'back' then return true end

	if item.playerList then
		if item.arg then
			module.UserListMenu(menu, item.self, item.name, item.source, table.unpack(item.arg))
		else
			module.UserListMenu(menu, item.self, item.name, item.source)
		end
		return true
	end
end

module.CloseMenu = function(item, m)
	if not(item) or item.name == 'close' then
		m:destroy()

		if #module.MenuHiddenList ~= 0 then
			for k, menu in ipairs(module.MenuHiddenList) do
				menu:destroy()
			end

			module.MenuHiddenList = {}
		end
	end
end

module.BackMenu = function(item, m, targetM)
	if targetM and item.name == 'back' then
		m:destroy()

		targetM:show()
		targetM:focus()

		module.MenuHiddenList[#module.MenuHiddenList] = nil
	end
end
