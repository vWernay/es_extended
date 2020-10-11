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

  print("ensuring cache")

  if Config.Modules.cache.basicCachedTables then
    for _,tab in pairs(Config.Modules.cache.basicCachedTables) do
      if tab == "vehicles" then
        MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
          if result then
            for i=1,#result,1 do

              if  module.Cache["vehicles"] == nil then
                module.Cache["vehicles"] = {}
              end

              if  module.Cache["categories"] == nil then
                module.Cache["categories"] = {}
              end

              table.insert(module.Cache["vehicles"], {
                name          = result[i].name,
                model         = result[i].model,
                price         = result[i].price,
                category      = result[i].category,
                categoryLabel = result[i].category_label
              })
            end

            for k,v in pairs(module.Cache["vehicles"]) do
              if #module.Cache["categories"] > 0 then
                for i,j in pairs(module.Cache["categories"]) do
                  if v.category == j.category then
                    module.categoryAlreadyExists = true
                  end
                end

                if module.categoryAlreadyExists then
                  module.categoryAlreadyExists = false
                else
                  table.insert(module.Cache["categories"], {
                    category      = v.category,
                    categoryLabel = v.categoryLabel
                  })
                end
              else
                table.insert(module.Cache["categories"], {
                  category      = v.category,
                  categoryLabel = v.categoryLabel
                })
              end
            end

            -- -- THIS ENCODED ARRAY TO JSON TO TEST STORAGE
            -- MySQL.Async.execute('INSERT INTO test (data) VALUES (@data)', {
            -- 	['@data']         = json.encode(module.cache.vehicles)
            -- })

            print("finished caching ^5\"" .. "categories" .. "\"^7")
            print("finished caching ^5\"" .. "vehicles" .. "\"^7")
          else
            print("^1error caching vehicles^7")
          end
        end)
      else
        module.Cache[tab] = {}

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

        print("finished caching ^5\"" .. tab .. "\"^7")
      end
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
      print("finished caching ^5\"" .. tab .. "\"^7")
    end
  end

  Wait(1500)
  emit('esx:cacheReady')
end)

on('esx:startSave', function()
  if Config.Modules.cache.cachesToUpdate then
    for _,tab in pairs(Config.Modules.cache.cachesToUpdate) do
      if module.Cache[tab] then

      end
    end
  end
end)
