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

Account = {}

Account.Notify = function(account, transactionAmount, balance)
  utils.ui.showNotification(_U('account_notify_moneychange', _U('account_moniker'), transactionAmount, account, _U('account_moniker'), balance))
end

Account.NotEnoughMoney = function(account, money)
  utils.ui.showNotification(_U('account_notify_not_enough_money', _U('account_moniker'), money, account))
end

Account.TransactionError = function(account)
  utils.ui.showNotification(_U('account_notify_transaction_error', account))
end
