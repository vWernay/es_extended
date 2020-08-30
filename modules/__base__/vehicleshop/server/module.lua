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

module.cache            = {}
module.cache.categories = {}
module.cache.vehicles   = {}

module.excessPlateLength = function(plate, plateUseSpace, plateLetters, plateNumbers)
    local checkedPlate = tostring(plate)
    local plateLength = string.len(checkedPlate)

    if plateLength > 8 then
        print("^1Generated plate is more than 8 characters. FiveM does not support this.")
        return true
    else
        return false
    end
end
