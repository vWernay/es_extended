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


ESX.SetInterval(5000, function()
  if module.Cache["owned_vehicles"] then
    for k,v in pairs(module.Cache["owned_vehicles"]) do
      for l,w in pairs(module.Cache["owned_vehicles"][k]) do
        for m,x in pairs(module.Cache["owned_vehicles"][k][l]) do
          for n,y in pairs(module.Cache["owned_vehicles"][k][l][m]) do
            if y then
              print(n .. " | " .. tostring(y))
            end
          end
        end
      end
    end
  end
end)