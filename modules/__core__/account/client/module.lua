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
M('ui.hud')

module.Dict          = "cellphone@"
module.InAnim        = "cellphone_text_in"
module.OutAnim       = "cellphone_text_out"
module.IdleAnim      = "cellphone_text_read_base"
module.WalletShowing = false

Account = {}
Account.Ready, Account.Frame, Account.isPaused = false, nil, false

Account.Notify = function(account, transactionAmount, balance)
  utils.ui.showNotification(_U('account_notify_moneychange', _U('account_moniker'), transactionAmount, account, _U('account_moniker'), balance))
end

Account.NotEnoughMoney = function(account, money)
  utils.ui.showNotification(_U('account_notify_not_enough_money', _U('account_moniker'), money, account))
end

Account.TransactionError = function(account)
  utils.ui.showNotification(_U('account_notify_transaction_error', account))
end

Account.ShowMoneyCommand = function()
  local Accounts = {}

  request('esx:account:getPlayerAccounts', function(data)
    if data then
      if not module.WalletShowing then
        module.WalletShowing = true
        local Accounts = {}
        local index = 0

        for k,v in pairs(Config.Modules.Account.AccountsIndex) do
          if data[v] and not Accounts[v] then
            index = index + 1
            table.insert(Accounts, {
              id = index,
              type = v,
              amount = data[v]
            })
          end
        end

        module.WalletAnimation(PlayerPedId(), Accounts)
      end
    else
      module.WalletShowing = false
    end
  end)
end

Account.ShowMoney = function()
  local Accounts = {}

  request('esx:account:getPlayerAccounts', function(data)
    if data then
      local Accounts = {}
      local index = 0

      for k,v in pairs(Config.Modules.Account.AccountsIndex) do
        if data[v] and not Accounts[v] then
          index = index + 1
          table.insert(Accounts, {
            id = index,
            type = v,
            amount = data[v]
          })
        end

        Citizen.Wait(900)
      end

      module.Frame:postMessage({
        data = Accounts
      })
    end
  end)
end

module.WalletAnimation = function(ped, accounts)
  if (DoesEntityExist(ped) and not IsEntityDead(ped)) then
    ClearPedTasks(ped)

    if IsPedInAnyVehicle(ped, false) then
      module.Dict = module.Dict .. "in_car@ds"
    end

    if not HasAnimDictLoaded(module.Dict) then
      RequestAnimDict(module.Dict)
    end

    if HasAnimDictLoaded(module.Dict)then
      AttachEntityToEntity(prop, ped, module.Bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
      TaskPlayAnim(ped, module.Dict, module.InAnim, 4.0, -1, -1, 50, 0, false, false, false)

      Citizen.Wait(157)

      StopAnimTask(ped, module.Dict, module.InAnim, 1.0)
      TaskPlayAnim(ped, module.Dict, module.IdleAnim, 8.0, -8.0, 1000, 1, 1.0, false, false, false)

      module.Frame:postMessage({
        data = accounts
      })

      Citizen.Wait(900)

      StopAnimTask(ped, module.Dict, module.IdleAnim, 1.0)
      TaskPlayAnim(ped, module.Dict, module.OutAnim, 5.0, -1, -1, 50, 0, false, false, false)
      StopAnimTask(ped, module.Dict, module.OutAnim, 1.0)
      RemoveAnimDict(module.Dict)
      ClearPedTasks(ped)

      module.Dict = "cellphone@"
      module.WalletShowing = false
    end
  end
end

module.Frame = Frame('account', 'nui://' .. __RESOURCE__ .. '/modules/__core__/account/data/html/index.html', true)

module.Frame:on('load', function()
  module.Ready = true
  emit('esx:account:ready')
end)
