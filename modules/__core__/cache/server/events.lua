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
  if Config.Modules.cache.basicCachedTables then
    for _,tab in pairs(Config.Modules.cache.basicCachedTables) do
      if module.Cache[tab] == nil then
        module.Cache[tab] = {}
      end

      MySQL.Async.fetchAll('SELECT * FROM ' .. tab, {}, function(result)
        for _,data in ipairs(result) do
          local index = #module.Cache[tab]+1
          module.Cache[tab][index] = {}

          for k,v in pairs(data) do
            module.Cache[tab][index][k] = {}

            if type(v) == "string" and v:len() >= 2 and v:find("{") and v:find("}") then
              module.Cache[tab][index][k] = json.decode(v)
            else
              module.Cache[tab][index][k] = v
            end
          end
        end
      end)
    end
  end

  if Config.Modules.cache.identityCachedTables then
    for _,tab in pairs(Config.Modules.cache.identityCachedTables) do
      module.Cache[tab] = {}

      MySQL.Async.fetchAll('SELECT * FROM ' .. tab, {}, function(result)
        for i=1, #result, 1 do
          if result[i].identifier and result[i].id then
            if not module.Cache[tab][result[i].identifier] then
              module.Cache[tab][result[i].identifier] = {}
            end

            if not module.Cache[tab][result[i].identifier][result[i].id] then
              module.Cache[tab][result[i].identifier][result[i].id] = {}
            end

            for _,data in ipairs(result) do
              local index = #module.Cache[tab]+1
              module.Cache[tab][result[i].identifier][result[i].id][index] = {}

              for k,v in pairs(data) do
                module.Cache[tab][result[i].identifier][result[i].id][index][k] = {}

                if type(v) == "string" and v:len() >= 2 and v:find("{") and v:find("}") then
                  module.Cache[tab][result[i].identifier][result[i].id][index][k] = json.decode(v)
                else
                  module.Cache[tab][result[i].identifier][result[i].id][index][k] = v
                end
              end
            end
          end
        end
      end)
    end
  end
end)
