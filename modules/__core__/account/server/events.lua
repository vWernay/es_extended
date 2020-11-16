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

local Cache = M("cache")

on('esx:account:addMoney', function(account, money, player)
    Account.AddIdentityMoney(account, money, player)
end)

on('esx:account:removeMoney', function(account, money, player)
    Account.RemoveIdentityMoney(account, money, player)
end)

onRequest('esx:account:getPlayerAccounts', function(source, cb)
	local player = Player.fromId(source)

	local accounts = Cache.RetrieveAccounts(player.identifier, player:getIdentityId())

	if accounts then
	  cb(accounts)
	else
	  cb(nil)
	end
end)