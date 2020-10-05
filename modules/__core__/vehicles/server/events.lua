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

local Command = M("events")
local migrate = M('migrate')

on("esx:db:ready", function()
  migrate.Ensure("vehicles", "core")
end)

on("esx:startCache", function()
  MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
    if result then
      for i=1,#result,1 do

        if  module.cache.vehicles == nil then
          module.cache.vehicles = {}
        end

        if  module.cache.categories == nil then
          module.cache.categories = {}
        end

        table.insert(module.cache.vehicles, {
          name          = result[i].name,
          model         = result[i].model,
          price         = result[i].price,
          category      = result[i].category,
          categoryLabel = result[i].category_label
        })
      end

      for k,v in pairs(module.cache.vehicles) do
        if #module.cache.categories > 0 then
          for i,j in pairs(module.cache.categories) do
            if v.category == j.category then
              module.categoryAlreadyExists = true
            end
          end

          if module.categoryAlreadyExists then
            module.categoryAlreadyExists = false
          else
            table.insert(module.cache.categories, {
              category      = v.category,
              categoryLabel = v.categoryLabel
            })
          end
        else
          table.insert(module.cache.categories, {
            category      = v.category,
            categoryLabel = v.categoryLabel
          })
        end
      end

      -- -- THIS ENCODED ARRAY TO JSON TO TEST STORAGE
			-- MySQL.Async.execute('INSERT INTO test (data) VALUES (@data)', {
			-- 	['@data']         = json.encode(module.cache.vehicles)
			-- })

      print("^2available vehicles cached^7")
    else
      print("^1error caching vehicles^7")
    end
  end)
end)
