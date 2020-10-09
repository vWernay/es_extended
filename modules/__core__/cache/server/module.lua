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

module.Cache = {}


-- ESX.SetInterval(5000, function()
--   if module.Cache["owned_vehicles"] then
--     if module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"] then
--       print(true)
--     end

--     if module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1] then
--       print(true)
--     end

--     if module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1][1] then
--       print(true)
--     end

--     if module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1][1].identifier then
--       print(module.Cache["owned_vehicles"]["ea910a9e8f6a5d9386ddc923f5976453040f881d"][1][1].identifier)
--     end
--   end
-- end)