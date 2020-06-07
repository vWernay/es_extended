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


module.Config = run('data/config.lua', {vector3 = vector3})['Config']

module.Jobs = {}
module.RegisteredSocieties = {}

module.Init = function()

  local translations = run('data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('society', Config.Locale, translations)

end

module.GetSociety = function(name)
	for i=1, #module.RegisteredSocieties, 1 do
		if module.RegisteredSocieties[i].name == name then
			return module.RegisteredSocieties[i]
		end
	end
end

module.isBoss = function(playerId, job)
	local player = xPlayer.fromId(playerId)

	if player.job.name == job and player.job.grade_name == 'boss' then
		return true
	else
		print(('society: %s attempted open a society boss menu!'):format(player.identifier))
		return false
	end
end

module.WashMoneyCRON = function(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM society_moneywash', {}, function(result)
		for i=1, #result, 1 do
			local society = module.GetSociety(result[i].society)
			local player = xPlayer.fromIdentifier(result[i].identifier)

			-- add society money
			emit('esx_addonaccount:getSharedAccount', society.account, function(account)
				account.addMoney(result[i].amount)
			end)

			-- send notification if player is online
			if player then
				player.showNotification(_U('society:you_have_laundered', ESX.Math.GroupDigits(result[i].amount)))
			end

			MySQL.Async.execute('DELETE FROM society_moneywash WHERE id = @id', {
				['@id'] = result[i].id
			})
		end
	end)
end
