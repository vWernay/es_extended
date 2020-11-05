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

onRequest('status:getStatuses', function(source, cb)
	local player = Player.fromId(source)

	if Config.Modules.Cache.UseCache then
	  module.Cache.statuses = Cache.RetrieveEntryFromIdentityCache("identities", player.identifier, player:getIdentityId(), "status")

	  if module.Cache.statuses then
		module.Cache.alreadyHasStatus = true
		cb(module.Cache.statuses)
	  else
		module.Cache.statuses = {}

		for k,v in ipairs(Config.Modules.Status.StatusIndex) do
			if not module.Cache.statuses[v] then
				module.Cache.statuses[v] = Config.Modules.Status.DefaultValues[k]
			end
		end

		cb(module.Cache.statuses)
	  end
	else
		cb(nil)
	end
end)

onClient('status:updateStatus', function(status)
	local player = Player.fromId(source)
	if module.Cache.alreadyHasStatus then
		Cache.UpdateTableInIdentityCache("identities", player.identifier, player:getIdentityId(), Config.Modules.Status.StatusIndex, "status", "value", status)
	else
		Cache.InsertTableIntoIdentityCache("identities", player.identifier, player:getIdentityId(), Config.Modules.Status.StatusIndex, "status", "value", status)
	end
end)
