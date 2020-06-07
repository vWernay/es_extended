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
