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

on('esx:startCache', function()
  if Config.Modules.Cache.UseCache then
    print("ensuring cache")

    module.StartCache()

    Wait(1500)
    emit('esx:cacheReady')
  else
    Wait(1500)
    print('^2ready^7')
  end
end)

on('esx:saveCache', function()
  module.SaveCache()
end)
