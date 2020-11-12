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

	if Config.Modules.Cache.UseCache then
	  module.Cache.Accounts = Cache.RetrieveEntryFromIdentityCache("identities", player.identifier, player:getIdentityId(), "accounts")

	  if module.Cache.Accounts then
		cb(module.Cache.Accounts)
	  else
		module.Cache.Accounts = {}

		for k,v in ipairs(Config.Modules.Account.AccountsIndex) do
			print(tostring(v))
			if not module.Cache.Accounts[v] then
				module.Cache.Accounts[v] = Config.Modules.Account.DefaultValues[k]
			end
		end

		cb(module.Cache.Accounts)
	  end
	else
		cb(nil)
	end
end)