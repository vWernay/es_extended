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

module.categoryFound    = false

module.cache            = {}
module.cache.vehicles   = {}
module.cache.categories = {}

module.reloadVehicles = function()
	module.categoryFound    = false

	module.cache            = {}
	module.cache.vehicles   = {}
	module.cache.categories = {}

	MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
		if result then
			for i=1,#result,1 do

				if  module.cache.vehicles[result[i].category] == nil then
					module.cache.vehicles[result[i].category] = {}
				end

				table.insert(module.cache.vehicles[result[i].category], {
					name     = result[i].name,
					model    = result[i].model,
					price    = result[i].price,
					category = result[i].category
				})

			end

			for k,v in pairs(module.cache.vehicles) do

				for i=1, #module.cache.categories, 1 do
					if i == tostring(k) then
						module.categoryFound = true
					end
				end

				if not module.categoryFound then
					table.insert(module.cache.categories, tostring(k))
					module.categoryFound = false
				end
			end

			print("^2vehicles recached^7")
		else
			print("^1error recaching vehicles^7")
		end
	end)
end

module.getCategories = function()
	return module.cache.categories
end

module.getVehicles = function()
	return module.cache.vehicles
end