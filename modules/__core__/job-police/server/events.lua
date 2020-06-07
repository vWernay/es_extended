onRequest('job-police:GetPlayerInventory', function(source, cb, target_player)
    cb(module.getInventory(target_player))
end)

on('job-police:giveFine', function(category, price, target)

    local billing_category = tostring(category)

    if billing_category == "0" then
        billing_category = "Vehicle Offence"
    elseif billing_category == "1" then
        billing_category = "Minor Offence"
    elseif billing_category == "2" then
        billing_category = "Medium Offence"
    elseif billing_category == "3" then
        billing_category = "Major Offence"
    end

    -- Hook up billing
    -- Title = Billing_category
    -- Price = Price
    -- Target = Target

end)