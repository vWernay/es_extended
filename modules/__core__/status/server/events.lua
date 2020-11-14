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

onClient('esx:status:initialize', function()
  local player = Player.fromId(source)
  local identifier = player.identifier
  local id = player:getIdentityId()

	if not module.Cache.Statuses[identifier] then
    module.Cache.Statuses[identifier] = {}
	end

	if not module.Cache.Statuses[identifier][id] then
    module.Cache.Statuses[identifier][id] = {}
	end

	local statuses = Cache.RetrieveEntryFromIdentityCache("identities", player.identifier, player:getIdentityId(), "status")

  local config = Config.Modules.Status.StatusInfo

  for k,v in ipairs(Config.Modules.Status.StatusIndex) do
    if statuses then
      if statuses[v] then
        module.CreateStatus(identifier, id, v, config[v].color, config[v].iconType, config[v].icon, statuses[v], config[v].fadeType)
      else
        module.CreateStatus(identifier, id, v, config[v].color, config[v].iconType, config[v].icon, Config.Modules.Status.DefaultValues[k], config[v].fadeType)
      end
    else
      module.CreateStatus(identifier, id, v, config[v].color, config[v].iconType, config[v].icon, Config.Modules.Status.DefaultValues[k], config[v].fadeType)
    end
  end

  module.Ready = true
  module.StatusesCreated()
end)

onClient('esx:status:setStatus', function(statusName, value)
  module.SetStatus(statusName, value)
end)
