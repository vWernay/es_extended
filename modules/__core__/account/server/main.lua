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

local addMoneyCommand = Command("addmoney", "admin", _U('account_add_money'))
addMoneyCommand:addArgument("account", "string", _U('account_account_name'))
addMoneyCommand:addArgument("money", "number", _U('account_money_value'))
addMoneyCommand:addArgument("player", "player", _U('commandgeneric_playerid'))
addMoneyCommand:setHandler(function(player, args)
  if args.account and args.money then
	if not args.player then args.player = player end
	emit("esx:account:addMoney", args.account, args.money, args.player)
	return
  else
	if not args.account then
		emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('account_commandderror_account')}})
		return
	elseif not args.money then
		emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('account_commanderror_money')}})
		return
	end
  end
end)

local removeMoneyCommand = Command("removemoney", "admin", _U('account_remove_money'))
removeMoneyCommand:addArgument("account", "string", _U('account_account_name'))
removeMoneyCommand:addArgument("money", "number", _U('account_money_value'))
removeMoneyCommand:addArgument("player", "player", _U('commandgeneric_playerid'))
removeMoneyCommand:setHandler(function(player, args)
if args.account and args.money then
    if not args.player then args.player = player end
    emit("esx:account:removeMoney", args.account, args.money, args.player)
    return
  else
    if not args.account then
        emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('account_commandderror_account')}})
        return
    elseif not args.money then
        emitClient("chat:addMessage", player.source, {args = {'^1SYSTEM', _U('account_commanderror_money')}})
        return
    end
  end
end)

local showMoneyCommand = Command("money", "admin", _U('account_show_money_test'))
showMoneyCommand:setHandler(function(player, args)
  emitClient("esx:account:showMoney", player.source)
end)

addMoneyCommand:register()
removeMoneyCommand:register()
showMoneyCommand:register()