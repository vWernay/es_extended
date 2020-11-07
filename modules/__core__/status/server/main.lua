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

local utils = M('utils')
M("command")

local setStatus = Command("setStatus", "admin", _U('set_status'))
setStatus:addArgument("statusName", "string", _U('status_name'))
setStatus:addArgument("value", "number", _U('status_value'))
setStatus:addArgument("player", "player", _U('commandgeneric_playerid'))
setStatus:setHandler(function(player, args)
  if args.statusName and args.value then
	if not args.player then args.player = player end
	emitClient("status:setStatusCommand", args.player.source, args.statusName, args.value)
	return
  else
	if not args.statusName then
		emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('status_commandderror_statusName')}})
		return
	elseif not args.value then
		emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('status_commanderror_value')}})
		return
	end
  end
end)

setStatus:register()
