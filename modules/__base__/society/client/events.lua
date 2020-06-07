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

onServer('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		module.UpdateSocietyMoneyHUDElement(money)
	end
end)

onServer('esx:setJob', function(job)
	module.RefreshBossHUD()
end)

on('society:openBossMenu', function(society, options)
	module.OpenBossMenu(society, options)
end)

on('society:toggleSocietyHud', function( bool )

	-- No idea what this does but it exists in client/module.lua
	-- Rename bool to whatever this is supposed to do

end)

on('society:recruitPlayer', function(source, society)
	local closestDistance, closestPlayer = ESX.Game.GetClosestPlayer()

	if closestDistance < 5 and closestPlayer ~= -1 then
		emit('society:recruitTarget', society, closestPlayer)
	end
end)