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

module.getCacheByName = function(cacheName)
  if module.Cache[cacheName] then
    return module.Cache[cacheName]
  else
    return nil
  end
end

module.InsertIntoBasicCache = function(cacheName, updateData)
  if module.Cache[cacheName] then
    if Config.Modules.Cache.EnableDebugging then
      print("Inserting ^2" .. tostring(updateData) .. "^7 into module.Cache[" .. cacheName .. "]")
    end

    table.insert(module.Cache[cacheName], updateData)
  end
end

module.InsertIntoIdentityCache = function(cacheName, identifier, id, updateData)
  if module.Cache[cacheName] then
    if not module.Cache[cacheName][identifier] then
      module.Cache[cacheName][identifier] = {}
    end

    if not module.Cache[cacheName][identifier][id] then
      module.Cache[cacheName][identifier][id] = {}
    end

    if module.Cache[cacheName][identifier][id] then
      local index = #module.Cache[cacheName][identifier][id]+1

      if not module.Cache[cacheName][identifier][id][index] then
        module.Cache[cacheName][identifier][id][index] = {}
      end

      module.Cache[cacheName][identifier][id][index] = updateData

      return true
    else
      return false
    end
  end
end

module.InsertTableIntoIdentityCache = function(cacheName, identifier, id, queryIndex, table, field, data)
  if module.Cache[cacheName] then
    if not module.Cache[cacheName][identifier] then
      module.Cache[cacheName][identifier] = {}
    end

    if not module.Cache[cacheName][identifier][id] then
      module.Cache[cacheName][identifier][id] = {}
    end

    if not module.Cache[cacheName][identifier][id][table] then
      module.Cache[cacheName][identifier][id][table] = {}
    end

    for k,v in pairs(queryIndex) do
      if not module.Cache[cacheName][identifier][id][table][v] then
        module.Cache[cacheName][identifier][id][table][v] = {}
      end

      if data[v] then
        if data[v][field] then
          if Config.Modules.Cache.EnableDebugging then
            print("module.Cache["..cacheName.."]["..identifier.."]["..id.."]["..table.."]["..v.."] = " .. data[v][field])
          end
          module.Cache[cacheName][identifier][id][table][v] = data[v][field]
        end
      end
    end
  else
    return false
  end
end

module.AddValueInIdentityCache = function(cacheName, identifier, id, table, field, value)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        if module.Cache[cacheName][identifier][id][table] then
          for k,v in pairs(module.Cache[cacheName][identifier][id][table]) do
            if tostring(k) == tostring(field) then
              if module.Cache[cacheName][identifier][id][table][field] >= 0 then
                module.Cache[cacheName][identifier][id][table][field] = module.Cache[cacheName][identifier][id][table][field] + value

                local result = {
                  type = "success",
                  value = module.Cache[cacheName][identifier][id][table][field]
                }

                return result
              end
            end
          end
        else
          return false
        end
        return false
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end

module.RemoveValueInIdentityCache = function(cacheName, identifier, id, table, field, value)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        if module.Cache[cacheName][identifier][id][table] then
          for k,v in pairs(module.Cache[cacheName][identifier][id][table]) do
            if tostring(k) == tostring(field) then
              if module.Cache[cacheName][identifier][id][table][field] then
                if (module.Cache[cacheName][identifier][id][table][field] - value) > 0 then
                  module.Cache[cacheName][identifier][id][table][field] = module.Cache[cacheName][identifier][id][table][field] - value

                  local result = {
                    type = "success",
                    value = module.Cache[cacheName][identifier][id][table][field]
                  }

                  return result
                else
                  local result = {
                    type = "not_enough_money"
                  }

                  return result
                end
              end
            end
          end
        else
          return false
        end
        return false
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end

module.UpdateTableInIdentityCache = function(cacheName, identifier, id, queryIndex, table, field, data)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        if module.Cache[cacheName][identifier][id][table] then

          for k,v in pairs(queryIndex) do
            if module.Cache[cacheName][identifier][id][table][v] then
              if data[v] then
                if data[v][field] then
                  module.Cache[cacheName][identifier][id][table][v] = data[v][field]
                end
              end
            end
          end
        else
          return false
        end
        return false
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end

module.UpdateValueInIdentityCache = function(cacheName, identifier, id, lKey, lValue, key, value)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        for k,v in ipairs(module.Cache[cacheName][identifier][id]) do
          if v[lKey] and v[key] then
            if v[lKey] == lValue then
              if Config.Modules.Cache.EnableDebugging then
                print("module.Cache["..cacheName.."]["..identifier.."]["..id.."]["..k.."]["..key.."] = " .. value)
              end

              module.Cache[cacheName][identifier][id][k][key] = value

              return true
            end
          end
        end

        return false
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end

module.RetrieveEntryFromIdentityCache = function(cacheName, identifier, id, key)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        if module.Cache[cacheName][identifier][id][key] then
          return module.Cache[cacheName][identifier][id][key]
        else
          return nil
        end

        return nil
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end

module.RetrieveMatchedEntryFromIdentityCache = function(cacheName, identifier, id, key, value)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        for k,v in ipairs(module.Cache[cacheName][identifier][id]) do
          if v[key] then
            if v[key] == value then
              return module.Cache[cacheName][identifier][id][k]
            end
          end
        end

        return nil
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end

module.RetrieveEntryWithLinkerFromIdentityCache = function(cacheName, identifier, id, lKey, lValue, key, value)
  if module.Cache[cacheName] then
    if module.Cache[cacheName][identifier] then
      if module.Cache[cacheName][identifier][id] then
        for k,v in ipairs(module.Cache[cacheName][identifier][id]) do
          if v[lKey] and v[key] then
            if v[lKey] == lValue then
              return module.Cache[cacheName][identifier][id][k]
            end
          end
        end

        return nil
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end

module.UpdateBasicCache = function(cacheName, updateData)
  if module.Cache[cacheName] then
    table.insert(module.Cache[cacheName], updateData)

    return true
  else
    return false
  end
end

module.StartCache = function()
  if Config.Modules.Cache.BasicCachedTables then
    for _,tab in pairs(Config.Modules.Cache.BasicCachedTables) do
      if tab == "vehicles" then
        MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
          if result then
            for i=1,#result,1 do

              if module.Cache["vehicles"] == nil then
                module.Cache["vehicles"] = {}
              end

              if module.Cache["categories"] == nil then
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
          end
        end)
      elseif tab == "usedPlates" then
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles', {}, function(result)
          if result then

            if module.Cache["usedPlates"] == nil then
              module.Cache["usedPlates"] = {}
            end

            for i=1,#result,1 do
              table.insert(module.Cache["usedPlates"], result[i].plate)
            end
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
      end
    end
  end

  if Config.Modules.Cache.IdentityCachedTables then
    for _,tab in pairs(Config.Modules.Cache.IdentityCachedTables) do
      if tab == "identities" then
        module.Cache[tab] = {}

        MySQL.Async.fetchAll('SELECT * FROM ' .. tab, {}, function(result)
          for i=1, #result, 1 do
            if result[i].owner and result[i].id then
              if not module.Cache[tab][result[i].owner] then
                module.Cache[tab][result[i].owner] = {}
              end

              if not module.Cache[tab][result[i].owner][result[i].id] then
                module.Cache[tab][result[i].owner][result[i].id] = {}
              end

              for _,data in ipairs(result) do
                for k,v in pairs(data) do
                  if k == "status" or k == "accounts" then
                    local index = 0
                    if Config.Modules.Cache.EnableDebugging then
                      print("module.Cache["..tostring(tab).."]["..tostring(result[i].owner).."]["..tostring(result[i].id).."]["..tostring(k).."] = "..tostring(v))
                    end

                    module.Cache[tab][result[i].owner][result[i].id][k] = json.decode(v)
                  end
                end
              end
            end
          end
        end)
      else
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

              local index = 0

              for _,data in ipairs(result) do
                index = index + 1

                if not module.Cache[tab][result[i].identifier][result[i].id][index] then
                  module.Cache[tab][result[i].identifier][result[i].id][index] = {}
                end

                for k,v in pairs(data) do
                  if not module.Cache[tab][result[i].identifier][result[i].id][index][k] then
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
          end
        end)
      end
    end
  end
end

module.SaveCache = function()
  print("^2saving cache...^7")

  if Config.Modules.Cache.IdentityCachedTables then
    for _,tab in pairs(Config.Modules.Cache.IdentityCachedTables) do
      if tab == "owned_vehicles" then
        if module.Cache[tab] then
          for k,_ in pairs(module.Cache[tab]) do
            for k2,_ in pairs(module.Cache[tab][k]) do
              for _,data in ipairs(module.Cache[tab][k][k2]) do

                local plate = tostring(data["plate"])

                MySQL.Async.fetchAll('SELECT plate FROM owned_vehicles WHERE plate = @plate', {
                  ['@plate'] = plate
                }, function(result)
                  if result[1] then
                    if Config.Modules.Cache.EnableDebugging then
                      print("updating owned vehicles with the plates: ^2" .. tostring(data["plate"]) .. "^7")
                    end

                    MySQL.Async.execute('UPDATE owned_vehicles SET id = @id, identifier = @identifier, vehicle = @vehicle, stored = @stored, sold = @sold WHERE plate = @plate', {
                      ['@id']         = tonumber(data["id"]),
                      ['@identifier'] = tostring(data["identifier"]),
                      ['@vehicle']    = json.encode(data["vehicle"]),
                      ['@stored']     = tonumber(data["stored"]),
                      ['@sold']       = tonumber(data["sold"]),
                      ['@plate']      = tostring(data["plate"])
                    })
                  else
                    if Config.Modules.Cache.EnableDebugging then
                      print("inserting owned vehicles with the plates: ^2" .. tostring(data["plate"]) .. "^7")
                    end

                    MySQL.Async.execute('INSERT INTO owned_vehicles (id, identifier, plate, model, sell_price, vehicle, stored, sold) VALUES (@id, @identifier, @plate, @model, @sell_price, @vehicle, @stored, @sold)', {
                      ['@id']         = tonumber(data["id"]),
                      ['@identifier'] = tostring(data["identifier"]),
                      ['@plate']      = tostring(data["plate"]),
                      ['@model']      = tostring(data["model"]),
                      ['@sell_price'] = tonumber(data["sell_price"]),
                      ['@vehicle']    = data["vehicle"],
                      ['@stored']     = tonumber(data["stored"]),
                      ['@sold']       = tonumber(data["sold"])
                    })
                  end
                end)
              end
            end
          end
        end
      elseif tab == "identities" then
        if module.Cache[tab] then
          for k,v in pairs(module.Cache[tab]) do
            for k2,v2 in pairs(module.Cache[tab][k]) do
              for k3,data in pairs(module.Cache[tab][k][k2]) do
                if k3 == "status" then
                  if Config.Modules.Cache.EnableDebugging then
                    print("Updating Status In Cache For : ^2" .. tostring(k) .. "^7")
                  end

                  MySQL.Async.execute('UPDATE identities SET status = @status WHERE id = @id AND owner = @owner', {
                    ['@status'] = json.encode(data),
                    ['@id']     = tonumber(k2),
                    ['@owner']  = tostring(k)
                  })
                elseif k3 == "accounts" then
                  if Config.Modules.Cache.EnableDebugging then
                    print("Updating Accounts In Cache For : ^2" .. tostring(k) .. "^7")
                  end

                  MySQL.Async.execute('UPDATE identities SET accounts = @accounts WHERE id = @id AND owner = @owner', {
                    ['@accounts'] = json.encode(data),
                    ['@id']     = tonumber(k2),
                    ['@owner']  = tostring(k)
                  })
                end
              end
            end
          end
        end
      end
    end
  end
end
