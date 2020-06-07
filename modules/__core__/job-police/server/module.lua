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

M('events')

module.getInventory = function(target_player)

    local target = xPlayer.fromId(target_player)

    local items = target.inventory
    local target_inventory = {}

    for k,v in ipairs(items) do
        table.insert( target_inventory, v.name)

        table.insert( target_inventory[v.name], {
            label   = v.label,
            count   = k.count,
            type    = v.type
        })
    end

    return target_inventory
end

--[[

    v.name = {
        label   = v.label,
        type    = v.type,
        count   = k.count
    }

]]--
